import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/client_model.dart';

// TreeLinePainter - Kategori ağacı çizgileri çizer
class TreeLinePainter extends CustomPainter {
  final bool isLast;
  final Color color;

  TreeLinePainter({
    required this.isLast,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final verticalStart = Offset(10, 0);
    final verticalEnd = Offset(10, size.height);
    final horizontalEnd = Offset(size.width - 2, size.height / 2);

    // Dikey çizgi (son değilse tam uzunluk, sonsa yarı)
    if (isLast) {
      canvas.drawLine(
        verticalStart,
        Offset(10, size.height / 2),
        paint,
      );
    } else {
      canvas.drawLine(
        verticalStart,
        verticalEnd,
        paint,
      );
    }

    // Yatay çizgi
    canvas.drawLine(
      Offset(10, size.height / 2),
      horizontalEnd,
      paint,
    );
  }

  @override
  bool shouldRepaint(TreeLinePainter oldDelegate) {
    return oldDelegate.isLast != isLast || oldDelegate.color != color;
  }
}

class FinancialMattersScreen extends StatefulWidget {
  const FinancialMattersScreen({super.key});

  @override
  State<FinancialMattersScreen> createState() =>
      _FinancialMattersScreenState();
}

class FinancialData {
  final String id;
  final String fullName;
  final String tcNo;
  final double agreedAmount;
  final double paidAmount;
  final String paymentType;
  final double accountBalance;

  FinancialData({
    required this.id,
    required this.fullName,
    required this.tcNo,
    required this.agreedAmount,
    required this.paidAmount,
    required this.paymentType,
    this.accountBalance = 0,
  });

  double get debt => agreedAmount - paidAmount;
  bool get isPending => debt > 0;
  double get percentage =>
      agreedAmount > 0 ? ((paidAmount / agreedAmount) * 100).clamp(0, 100) : 0;
}

class ExpenseCategory {
  final String name;
  List<String>? subCategories;
  bool isExpanded;
  final List<ExpenseItem> items;

  ExpenseCategory({
    required this.name,
    this.subCategories,
    this.isExpanded = false,
    this.items = const [],
  });

  // JSON dönüşümleri
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subCategories': subCategories,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      name: json['name'] ?? '',
      subCategories: List<String>.from(json['subCategories'] ?? []),
      items: List<ExpenseItem>.from(
        (json['items'] ?? []).map((item) => ExpenseItem.fromJson(item)),
      ),
    );
  }
}

class ExpenseItem {
  final String id;
  final String categoryName;
  final String? subCategoryName;
  final double amount;
  final DateTime date;
  final String? description;
  final String? info;

  ExpenseItem({
    required this.id,
    required this.categoryName,
    this.subCategoryName,
    required this.amount,
    required this.date,
    this.description,
    this.info,
  });

  // JSON dönüşümleri
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'info': info,
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      subCategoryName: json['subCategoryName'],
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
      info: json['info'],
    );
  }
}

class _FinancialMattersScreenState extends State<FinancialMattersScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late List<FinancialData> _financialData = [];
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all';
  late List<ExpenseCategory> _expenseCategories;

  final List<ExpenseCategory> _defaultCategories = [
    ExpenseCategory(
      name: 'Faturalar',
      items: [],
    ),
    ExpenseCategory(
      name: 'Çalışanlar',
      items: [],
    ),
    ExpenseCategory(
      name: 'Stopajlar',
      items: [],
    ),
    ExpenseCategory(
      name: 'Vergiler',
      items: [],
    ),
    ExpenseCategory(
      name: 'Harçlar',
      items: [],
    ),
    ExpenseCategory(
      name: 'Tebligat Giderleri',
      items: [],
    ),
    ExpenseCategory(
      name: 'Karar Harçları',
      items: [],
    ),
    ExpenseCategory(
      name: 'Noter Masrafları',
      items: [],
    ),
    ExpenseCategory(
      name: 'Mahkeme kararlarının tebliği ve icra masrafları',
      items: [],
    ),
    ExpenseCategory(
      name: 'Belge ve Delil Masrafları',
      subCategories: [
        'Bilirkişi ücretleri',
        'Tanık masrafları',
        'Belge temini ve fotokopi giderleri',
        'Tercüme giderleri',
      ],
      items: [],
    ),
    ExpenseCategory(
      name: 'Seyahat ve İletişim',
      subCategories: [
        'Mahkeme, icra dairesi veya müvekkil ziyaretleri için ulaşım giderleri',
        'Telefon, posta, kargo giderleri',
        'Danışma ücretleri',
        'Araştırma ve dosya hazırlık masrafları',
        'Gerekli belgelerin temini',
      ],
      items: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _expenseCategories = List.from(_defaultCategories);
    _loadExpensesFromPreferences();
    _loadFinancialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFinancialData();
    }
  }

  Future<void> _loadFinancialData() async {
    try {
      print('🔄 Mali İşler verisi yükleniyor...');
      final clients = await _databaseService.getAllClients();
      print('📊 Yüklenen müvekkil sayısı: ${clients.length}');
      
      final financialData = clients
          .map((client) {
            final data = FinancialData(
              id: client.id,
              fullName: '${client.firstName} ${client.lastName}',
              tcNo: client.tcNo,
              agreedAmount: client.agreedAmount,
              paidAmount: client.paidAmount,
              paymentType: 'Avukat Ücreti',
              accountBalance: client.remainingAmount,
            );
            print('  → ${data.fullName}: ${data.agreedAmount}₺ (Ödenen: ${data.paidAmount}₺)');
            return data;
          })
          .toList();
      
      print('✅ Mali İşler verisi başarıyla yüklendi');
      setState(() {
        _financialData = financialData;
        _isLoading = false;
      });
      print('🎯 Filtrelenen veri sayısı: ${_filteredData.length}');
    } catch (e) {
      print('❌ Mali İşler yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  List<FinancialData> get _filteredData {
    return _financialData.where((data) {
      final matchesSearch = data.fullName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          data.tcNo.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _filterType == 'all' ||
          (_filterType == 'pending' && data.isPending) ||
          (_filterType == 'completed' && !data.isPending);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkBackground,
              AppTheme.darkBackground.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Compact Header
              _buildCompactHeader(),
              // Tab Bar
              Container(
                color: Colors.white.withValues(alpha: 0.02),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.neonBlue,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                  labelColor: AppTheme.neonBlue,
                  tabs: const [
                    Tab(text: 'Müvekkillerim'),
                    Tab(text: 'Gider Kategorileri'),
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Clients
                    _buildClientsTab(),
                    // Tab 2: Expense Categories
                    _buildExpenseCategoriesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientsTab() {
    return Column(
      children: [
        // Search
        _buildCompactSearch(),
        // Content with RefreshIndicator
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFinancialData,
            color: AppTheme.neonBlue,
            backgroundColor: AppTheme.darkBackground,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.neonBlue,
                      ),
                    ),
                  )
                : _filteredData.isEmpty
                    ? _buildEmptyState()
                    : _buildCompactList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCategoriesTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...List.generate(
            _expenseCategories.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: _buildExpenseCategoryTile(index),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoryTile(int index) {
    final category = _expenseCategories[index];
    final hasSubCategories = category.subCategories != null && category.subCategories!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() => category.isExpanded = expanded);
          },
          title: Text(
            category.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.neonGreen.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: GestureDetector(
              onTap: () => _showSubCategoryDialog(category),
              child: const Icon(
                Icons.add,
                size: 18,
                color: AppTheme.neonGreen,
              ),
            ),
          ),
          children: [
            if (hasSubCategories)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: Column(
                  children: List.generate(
                    category.subCategories!.length,
                    (subIndex) {
                      final subCategory = category.subCategories![subIndex];
                      final isLast = subIndex == category.subCategories!.length - 1;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bağlantı çizgisi
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vertical line ve horizontal connector
                              SizedBox(
                                width: 20,
                                height: 40,
                                child: CustomPaint(
                                  painter: TreeLinePainter(
                                    isLast: isLast,
                                    color: AppTheme.neonBlue.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              // Alt kategori container
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 0),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.01),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _showCategoryDetailsDialog(category, subCategory),
                                          child: Text(
                                            subCategory,
                                            style: TextStyle(
                                              color: AppTheme.neonBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () =>
                                                _showEditSubCategoryDialog(
                                                    category, subIndex, subCategory),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(horizontal: 4),
                                              child: Icon(
                                                Icons.edit,
                                                size: 14,
                                                color: AppTheme.neonBlue
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                category.subCategories!
                                                    .removeAt(subIndex);
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(horizontal: 4),
                                              child: Icon(
                                                Icons.delete_outline,
                                                size: 14,
                                                color: AppTheme.neonOrange
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isLast) const SizedBox(height: 0),
                        ],
                      );
                    },
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Alt kategorisi bulunmamaktadır',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSubCategoryDialog(ExpenseCategory category) {
    final newSubCategoryController = TextEditingController();
    final focusNode = FocusNode();
    int? editingIndex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: AppTheme.darkBackground,
          title: Text(
            '${category.name} - Alt Kategoriler',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Input alanı
                TextField(
                  focusNode: focusNode,
                  controller: newSubCategoryController,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    // Enter tuşuna basıldığında ekle butonu gibi çalış
                    final inputText = newSubCategoryController.text.trim();
                    if (inputText.isNotEmpty) {
                      dialogSetState(() {
                        if (editingIndex != null) {
                          // Düzenleme
                          category.subCategories![editingIndex!] = inputText;
                          editingIndex = null;
                        } else {
                          // Yeni ekleme
                          category.subCategories ??= [];
                          category.subCategories!.add(inputText);
                        }
                        newSubCategoryController.clear();
                      });
                      // Verileri kaydet
                      _saveExpensesToPreferences();
                      setState(() {});
                      // Fokus geri getir ve imleç yanıp sönmeye başla
                      Future.delayed(const Duration(milliseconds: 100), () {
                        focusNode.requestFocus();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: editingIndex != null
                        ? 'Alt kategoriyı düzenle'
                        : 'Yeni alt kategori adı',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.neonBlue,
                      ),
                    ),
                    suffixIcon: editingIndex != null
                        ? GestureDetector(
                            onTap: () {
                              dialogSetState(() {
                                newSubCategoryController.clear();
                                editingIndex = null;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: AppTheme.neonOrange,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Mevcut alt kategoriler
                if (category.subCategories != null &&
                    category.subCategories!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mevcut Alt Kategoriler (${category.subCategories!.length})',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.01),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                              category.subCategories!.length,
                              (index) {
                                final subCat =
                                    category.subCategories![index];
                                final isEditing = editingIndex == index;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isEditing
                                        ? AppTheme.neonBlue.withValues(
                                            alpha: 0.1)
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white.withValues(
                                            alpha: 0.05),
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          subCat,
                                          style: TextStyle(
                                            color: isEditing
                                                ? AppTheme.neonBlue
                                                : Colors.white
                                                    .withValues(alpha: 0.7),
                                            fontSize: 11,
                                            fontWeight: isEditing
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          // Edit butonu
                                          GestureDetector(
                                            onTap: () {
                                              dialogSetState(() {
                                                editingIndex = index;
                                                newSubCategoryController
                                                    .text = subCat;
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                size: 14,
                                                color: AppTheme.neonBlue
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                          // Delete butonu
                                          GestureDetector(
                                            onTap: () {
                                              dialogSetState(() {
                                                category.subCategories!
                                                    .removeAt(index);
                                                if (editingIndex ==
                                                    index) {
                                                  editingIndex = null;
                                                  newSubCategoryController
                                                      .clear();
                                                }
                                              });
                                              // Verileri kaydet
                                              _saveExpensesToPreferences();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              child: Icon(
                                                Icons.delete_outline,
                                                size: 14,
                                                color: AppTheme.neonOrange
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.01),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Henüz alt kategori eklenmemiş',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kapat',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                final inputText = newSubCategoryController.text.trim();
                if (inputText.isNotEmpty) {
                  dialogSetState(() {
                    if (editingIndex != null) {
                      // Düzenleme
                      category.subCategories![editingIndex!] = inputText;
                      editingIndex = null;
                    } else {
                      // Yeni ekleme
                      category.subCategories ??= [];
                      category.subCategories!.add(inputText);
                    }
                    newSubCategoryController.clear();
                  });
                  // Verileri kaydet
                  _saveExpensesToPreferences();
                  setState(() {});
                }
              },
              child: Text(
                editingIndex != null ? 'Güncelle' : 'Ekle',
                style: const TextStyle(color: AppTheme.neonGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetailsDialog(
      ExpenseCategory category, String subCategory) {
    final infoController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: AppTheme.darkBackground,
          title: Text(
            '$subCategory',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ana kategori bilgisi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.neonBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Ana Kategori: ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            color: AppTheme.neonBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Gider Ekleme Formu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.neonGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bilgi',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bilgi
                      TextField(
                        controller: infoController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppTheme.neonBlue,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Bilgi (ör: Sekreter maaşı)',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3)),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.neonBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Açıklama
                      TextField(
                        controller: descriptionController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppTheme.neonBlue,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Açıklama (ör: Bu ay ödenen)',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3)),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.neonBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tutar
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppTheme.neonBlue,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Tutar (ör: 800.00)',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3)),
                          suffixText: '₺',
                          suffixStyle: const TextStyle(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.neonBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Giderler Listesi
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.01),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Bilgi',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Açıklama',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Tutar',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  'İşlem',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: category.items.isEmpty
                                  ? [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          'Henüz gider eklenmemiş',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.4),
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ]
                                  : List.generate(
                                      category.items.length,
                                      (idx) {
                                        final item = category.items[idx];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.white
                                                    .withValues(alpha: 0.05),
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  item.info ?? '-',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showExpenseDetailDialog(item);
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.description ?? '-',
                                                        style: const TextStyle(
                                                          color: AppTheme.neonBlue,
                                                          fontSize: 11,
                                                          decoration: TextDecoration.underline,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        item.date
                                                            .toString()
                                                            .split(' ')[0],
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withValues(
                                                                  alpha: 0.4),
                                                          fontSize: 9,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${item.amount.toStringAsFixed(2)}₺',
                                                  style: const TextStyle(
                                                    color: AppTheme.neonGreen,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 50,
                                                child: Center(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      dialogSetState(() {
                                                        category.items
                                                            .removeAt(idx);
                                                      });
                                                      // Verileri kaydet
                                                      _saveExpensesToPreferences();
                                                    },
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      size: 14,
                                                      color: AppTheme
                                                          .neonOrange
                                                          .withValues(
                                                              alpha: 0.6),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final info = infoController.text.trim();
                final desc = descriptionController.text.trim();
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;

                if (info.isNotEmpty && desc.isNotEmpty && amount > 0) {
                  dialogSetState(() {
                    category.items.add(
                      ExpenseItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        categoryName: category.name,
                        subCategoryName: subCategory,
                        amount: amount,
                        date: DateTime.now(),
                        description: desc,
                        info: info,
                      ),
                    );
                    infoController.clear();
                    descriptionController.clear();
                    amountController.clear();
                  });
                  // Verileri kaydet
                  _saveExpensesToPreferences();
                  setState(() {});
                }
              },
              child: const Text(
                'Ekle',
                style: TextStyle(color: AppTheme.neonGreen),
              ),
            ),
            TextButton(
              onPressed: () {
                final info = infoController.text.trim();
                final desc = descriptionController.text.trim();
                final amount = amountController.text.trim();

                // Eğer veri yazmışsa uyarı göster
                if (info.isNotEmpty || desc.isNotEmpty || amount.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (alertContext) => AlertDialog(
                      backgroundColor: AppTheme.darkBackground,
                      title: const Text(
                        'Veriyi Kaydetmediniz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'Kaydetmek ister misiniz?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      actions: [
                        // Hayır - Direkt Kapat
                        TextButton(
                          onPressed: () {
                            Navigator.pop(alertContext); // Uyarı dialog'unu kapat
                            Navigator.pop(context); // Ana dialog'u kapat
                          },
                          child: const Text(
                            'Hayır',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        // Evet - Kaydet ve Kapat
                        TextButton(
                          onPressed: () {
                            Navigator.pop(alertContext); // Uyarı dialog'unu kapat
                            
                            // Ekle butonunun mantığını çalıştır
                            final info = infoController.text.trim();
                            final amountValue =
                                double.tryParse(amountController.text.trim()) ?? 0;

                            if (desc.isNotEmpty && info.isNotEmpty && amountValue > 0) {
                              dialogSetState(() {
                                category.items.add(
                                  ExpenseItem(
                                    id: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    categoryName: category.name,
                                    subCategoryName: subCategory,
                                    amount: amountValue,
                                    date: DateTime.now(),
                                    description: desc,
                                    info: info,
                                  ),
                                );
                                infoController.clear();
                                descriptionController.clear();
                                amountController.clear();
                              });
                              _saveExpensesToPreferences();
                              setState(() {});
                            }
                            Navigator.pop(context); // Ana dialog'u kapat
                          },
                          child: const Text(
                            'Evet',
                            style: TextStyle(color: AppTheme.neonGreen),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Veri yazmamışsa direkt kapat
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Kapat',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSubCategoryDialog(
      ExpenseCategory category, int index, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBackground,
        title: const Text(
          'Alt Kategorisi Düzenle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Alt kategori adı',
            hintStyle:
                TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.neonBlue,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  category.subCategories![index] = controller.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Kaydet',
              style: TextStyle(color: AppTheme.neonGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetailDialog(ExpenseItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBackground,
        title: const Text(
          'Gider Detayı',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bilgi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.neonBlue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bilgi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.info ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Açıklama
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.neonBlue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Açıklama',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tutar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.neonGreen.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tutar',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item.amount.toStringAsFixed(2)}₺',
                      style: const TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tarih
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tarih',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.date.toString().split(' ')[0],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Kategori Bilgisi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.categoryName,
                      style: const TextStyle(
                        color: AppTheme.neonBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.subCategoryName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Alt Kategori: ${item.subCategoryName}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kapat',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neonBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.goldColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.attach_money,
              color: AppTheme.goldColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mali İşler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${_financialData.length} Kayıt',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white.withValues(alpha: 0.01),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Ara...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.neonBlue.withValues(alpha: 0.5),
                size: 18,
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.neonBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.neonBlue.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.neonBlue.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          // Filter Chips - Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCompactFilterChip('Tümü', 'all', Icons.apps),
                const SizedBox(width: 6),
                _buildCompactFilterChip('Beklemede', 'pending', Icons.schedule),
                const SizedBox(width: 6),
                _buildCompactFilterChip(
                    'Tamamlandı', 'completed', Icons.check_circle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterChip(String label, String value, IconData icon) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.neonBlue.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.neonBlue
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? AppTheme.neonBlue : Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.neonBlue : Colors.white54,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Kayıt Bulunamadı',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Arama kriterlerine uygun kayıt yok'
                : 'Henüz mali kayıt eklenmemiş',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildDetailedCard(index);
      },
    );
  }

  Widget _buildDetailedCard(int index) {
    final data = _filteredData[index];
    final percentage = data.percentage;
    final statusColor = data.isPending ? AppTheme.neonOrange : AppTheme.neonGreen;

    return FadeInUp(
      delay: Duration(milliseconds: index * 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Üst Satır: Ad, Soyad, TC
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TC Kimlik: ${data.tcNo}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      data.isPending ? 'BEKLEMEDE' : 'TAMAMLANDI',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
              ),
              const SizedBox(height: 12),
              // Mali Bilgiler Grid
              Row(
                children: [
                  // Anlaşılan Ücret
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anlaşılan Ücret',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${data.agreedAmount.toStringAsFixed(2)}₺',
                          style: const TextStyle(
                            color: AppTheme.neonBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Peşin Ödenen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peşin Ödenen',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${data.paidAmount.toStringAsFixed(2)}₺',
                          style: const TextStyle(
                            color: AppTheme.neonGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Hesap Bakiyesi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hesap Bakiyesi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${data.debt.toStringAsFixed(2)}₺',
                          style: TextStyle(
                            color: data.isPending ? AppTheme.neonOrange : AppTheme.neonGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Ödeme Türü
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ödeme Türü',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppTheme.goldColor.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            data.paymentType,
                            style: const TextStyle(
                              color: AppTheme.goldColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ödeme İlerleme',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SharedPreferences İşlemleri ====================
  Future<void> _saveExpensesToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(
        _expenseCategories.map((cat) => cat.toJson()).toList(),
      );
      await prefs.setString('expense_categories', jsonData);
      print('✅ Giderler kaydedildi: ${_expenseCategories.length} kategori');
    } catch (e) {
      print('❌ Kaydetme hatası: $e');
    }
  }

  Future<void> _loadExpensesFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('expense_categories');
      
      if (jsonData != null && jsonData.isNotEmpty) {
        final decodedData = jsonDecode(jsonData) as List;
        final loadedCategories = decodedData
            .map((cat) => ExpenseCategory.fromJson(cat as Map<String, dynamic>))
            .toList();
        
        setState(() {
          _expenseCategories = loadedCategories;
        });
        print('✅ Giderler yüklendi: ${_expenseCategories.length} kategori');
      } else {
        print('ℹ️ Kaydedilmiş gider bulunamadı, varsayılanlar kullanılıyor');
      }
    } catch (e) {
      print('❌ Yükleme hatası: $e');
      // Hata durumunda varsayılanları kullan
      setState(() {
        _expenseCategories = List.from(_defaultCategories);
      });
    }
  }
}

