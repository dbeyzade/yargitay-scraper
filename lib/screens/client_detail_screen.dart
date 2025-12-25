import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/app_theme.dart';
import '../models/client_model.dart';
import '../models/payment_model.dart';
import '../models/court_date_model.dart';
import '../services/database_service.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/neon_button.dart';
import '../widgets/animated_text_field.dart';
import 'add_court_date_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> clientData;

  const ClientDetailScreen({super.key, required this.clientData});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen>
    with TickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  
  Client? _client;
  late TabController _tabController;
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  
  List<Payment> _payments = [];
  List<PaymentCommitment> _commitments = [];
  List<CourtDate> _courtDates = [];
  List<Map<String, dynamic>> _requests = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _initAnimations();
    _loadClientDetails();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadClientDetails() async {
    final clientId = widget.clientData['id'];

    final client = await _dbService.getClientById(clientId);
    
    final payments = await _dbService.getClientPayments(clientId);
    final commitments = await _dbService.getClientPaymentCommitments(clientId);
    final courtDates = await _dbService.getClientCourtDates(clientId);
    final requests = await _dbService.getClientRequests(clientId);
    
    setState(() {
      _client = client;
      _payments = payments;
      _commitments = commitments;
      _courtDates = courtDates;
      _requests = requests;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;

    if (_isLoading && client == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (client == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Müvekkil Detayı'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Müvekkil bilgisi yüklenemedi'),
        ),
      );
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF0A0E21),
                    const Color(0xFF1A237E),
                    _backgroundController.value * 0.15,
                  )!,
                  const Color(0xFF0A0E21),
                  Color.lerp(
                    const Color(0xFF0A0E21),
                    const Color(0xFF00BCD4),
                    _backgroundController.value * 0.1,
                  )!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(client),
              _buildClientInfoCard(client),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentsTab(client),
                    _buildCommitmentsTab(),
                    _buildCourtDatesTab(),
                    _buildDocumentsTab(),
                    _buildRequestsTab(),
                    _buildExpensesTab(),
                    _buildCategoriesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Client client) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          FadeInLeft(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          FadeInDown(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'TC: ${client.tcNo}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          FadeInRight(
            child: Row(
              children: [
                IconNeonButton(
                  onPressed: () => _printClientInfo(client),
                  icon: Icons.print,
                  color: AppTheme.neonBlue,
                  tooltip: 'Yazdır',
                ),
                const SizedBox(width: 10),
                IconNeonButton(
                  onPressed: () => _showEditClientDialog(client),
                  icon: Icons.edit,
                  color: AppTheme.neonGreen,
                  tooltip: 'Düzenle',
                ),
                const SizedBox(width: 10),
                IconNeonButton(
                  onPressed: () => _confirmDeleteClient(client),
                  icon: Icons.delete_forever,
                  color: AppTheme.neonOrange,
                  tooltip: 'Sil',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoCard(Client client) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(25),
          child: Row(
            children: [
              // Photo
              Hero(
                tag: 'client_photo_${client.id}',
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(
                              0.3 + (_glowController.value * 0.3),
                            ),
                            blurRadius: 15 + (_glowController.value * 10),
                            spreadRadius: 2 + (_glowController.value * 3),
                          ),
                        ],
                      ),
                      child: client.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                client.photoUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 25),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.phone, client.phoneNumber),
                    _buildInfoRow(Icons.location_on, client.address),
                    if (client.vasiName != null)
                      _buildInfoRow(Icons.person_outline, 'Vasi: ${client.vasiName}'),
                    if (client.birthDate != null)
                      _buildInfoRow(Icons.cake, 'Doğum: ${client.birthDate}'),
                  ],
                ),
              ),
              
              // Financial summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildAmountDisplay(
                      'Anlaşılan',
                      client.agreedAmount,
                      AppTheme.goldColor,
                    ),
                    const SizedBox(height: 15),
                    _buildAmountDisplay(
                      'Ödenen',
                      client.paidAmount,
                      AppTheme.neonGreen,
                    ),
                    const SizedBox(height: 15),
                    _buildAmountDisplay(
                      'Kalan',
                      client.remainingAmount,
                      AppTheme.neonOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.neonBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        Text(
          '${NumberFormat('#,###').format(amount)} ₺',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppTheme.cardColor.withOpacity(0.5),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppTheme.primaryGradient,
          boxShadow: AppTheme.glowingShadow(AppTheme.primaryColor),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Ödemeler'),
          Tab(text: 'Taahhütler'),
          Tab(text: 'Duruşmalar'),
          Tab(text: 'Belgeler'),
          Tab(text: 'Talepler'),
          Tab(text: 'Masraflar'),
          Tab(text: 'Kategoriler'),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 300))
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildPaymentsTab(Client client) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ödeme Geçmişi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconNeonButton(
                    onPressed: () => _printPayments(),
                    icon: Icons.print,
                    color: AppTheme.neonBlue,
                    size: 40,
                    tooltip: 'Yazdır',
                  ),
                  const SizedBox(width: 10),
                  NeonButton(
                    onPressed: () => _showAddPaymentDialog(client),
                    label: 'Ödeme Ekle',
                    icon: Icons.add,
                    color: AppTheme.neonGreen,
                    width: 150,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_payments.isEmpty)
            _buildEmptyState('Henüz ödeme kaydı bulunmuyor', Icons.payment)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                return _buildPaymentCard(_payments[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: payment.isIncome
                      ? AppTheme.neonGreen.withOpacity(0.2)
                      : AppTheme.neonOrange.withOpacity(0.2),
                ),
                child: Icon(
                  payment.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: payment.isIncome ? AppTheme.neonGreen : AppTheme.neonOrange,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.description ?? 'Ödeme',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(payment.paymentDate),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${payment.isIncome ? '+' : '-'}${NumberFormat('#,###').format(payment.amount)} ₺',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: payment.isIncome ? AppTheme.neonGreen : AppTheme.neonOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommitmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ödeme Taahhütleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconNeonButton(
                    onPressed: () {},
                    icon: Icons.print,
                    color: AppTheme.neonBlue,
                    size: 40,
                    tooltip: 'Yazdır',
                  ),
                  const SizedBox(width: 10),
                  NeonButton(
                    onPressed: () => _showAddCommitmentDialog(),
                    label: 'Taahhüt Ekle',
                    icon: Icons.add,
                    color: AppTheme.neonPurple,
                    width: 160,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_commitments.isEmpty)
            _buildEmptyState('Henüz ödeme taahhüdü bulunmuyor', Icons.schedule)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _commitments.length,
              itemBuilder: (context, index) {
                return _buildCommitmentCard(_commitments[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommitmentCard(PaymentCommitment commitment, int index) {
    final isOverdue = commitment.commitmentDate.isBefore(DateTime.now()) &&
        !commitment.isCompleted;
    
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: GlassmorphicContainer(
          borderColor: isOverdue ? Colors.redAccent : null,
          boxShadow: isOverdue
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: commitment.isCompleted
                      ? AppTheme.neonGreen.withOpacity(0.2)
                      : isOverdue
                          ? Colors.redAccent.withOpacity(0.2)
                          : AppTheme.neonPurple.withOpacity(0.2),
                ),
                child: Icon(
                  commitment.isCompleted
                      ? Icons.check
                      : isOverdue
                          ? Icons.warning
                          : Icons.schedule,
                  color: commitment.isCompleted
                      ? AppTheme.neonGreen
                      : isOverdue
                          ? Colors.redAccent
                          : AppTheme.neonPurple,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMMM yyyy', 'tr').format(commitment.commitmentDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (commitment.notes != null)
                      Text(
                        commitment.notes!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    if (commitment.hasAlarm)
                      Row(
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 14,
                            color: AppTheme.goldColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Hatırlatma aktif',
                            style: TextStyle(
                              color: AppTheme.goldColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(commitment.amount)} ₺',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: commitment.isCompleted
                      ? AppTheme.neonGreen
                      : AppTheme.goldColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourtDatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mahkeme Tarihleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconNeonButton(
                    onPressed: () {},
                    icon: Icons.print,
                    color: AppTheme.neonBlue,
                    size: 40,
                    tooltip: 'Yazdır',
                  ),
                  const SizedBox(width: 10),
                  NeonButton(
                    onPressed: () => _showAddCourtDateDialog(),
                    label: 'Duruşma Ekle',
                    icon: Icons.add,
                    color: AppTheme.neonOrange,
                    width: 160,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_courtDates.isEmpty)
            _buildEmptyState('Henüz duruşma kaydı bulunmuyor', Icons.gavel)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courtDates.length,
              itemBuilder: (context, index) {
                return _buildCourtDateCard(_courtDates[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCourtDateCard(CourtDate courtDate, int index) {
    final isUpcoming = courtDate.courtDate.isAfter(DateTime.now());
    final isToday = courtDate.courtDate.day == DateTime.now().day &&
        courtDate.courtDate.month == DateTime.now().month &&
        courtDate.courtDate.year == DateTime.now().year;
    
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: AnimatedGlassmorphicContainer(
          glowColor: isToday ? AppTheme.neonOrange : AppTheme.neonPurple,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: isToday ? AppTheme.goldGradient : AppTheme.primaryGradient,
                ),
                child: Column(
                  children: [
                    Text(
                      courtDate.courtDate.day.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'tr').format(courtDate.courtDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courtDate.courtName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Dosya No: ${courtDate.caseNumber}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(courtDate.courtDate),
                      style: TextStyle(
                        color: AppTheme.goldColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (courtDate.reminderOneDayBefore || courtDate.reminderOnDay)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppTheme.neonGreen.withOpacity(0.2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: AppTheme.neonGreen,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Hatırlatma',
                            style: TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gerekçeli Kararlar ve Belgeler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconNeonButton(
                    onPressed: () {},
                    icon: Icons.print,
                    color: AppTheme.neonBlue,
                    size: 40,
                    tooltip: 'Yazdır',
                  ),
                  const SizedBox(width: 10),
                  NeonButton(
                    onPressed: () => _pickAndAddDocument(),
                    label: 'Dosya Ekle',
                    icon: Icons.upload_file,
                    color: AppTheme.neonBlue,
                    width: 150,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildEmptyState('Henüz belge eklenmemiş', Icons.folder_open),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Müvekkil Talepleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconNeonButton(
                    onPressed: () {},
                    icon: Icons.print,
                    color: AppTheme.neonBlue,
                    size: 40,
                    tooltip: 'Yazdır',
                  ),
                  const SizedBox(width: 10),
                  NeonButton(
                    onPressed: () => _showAddRequestDialog(),
                    label: 'Talep Ekle',
                    icon: Icons.add,
                    color: AppTheme.neonGreen,
                    width: 150,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_requests.isEmpty)
            _buildEmptyState('Henüz talep kaydı bulunmuyor', Icons.assignment)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(_requests[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (request['is_completed'] ?? false)
                      ? AppTheme.neonGreen.withOpacity(0.2)
                      : AppTheme.neonPurple.withOpacity(0.2),
                ),
                child: Icon(
                  (request['is_completed'] ?? false)
                      ? Icons.check
                      : Icons.pending,
                  color: (request['is_completed'] ?? false)
                      ? AppTheme.neonGreen
                      : AppTheme.neonPurple,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['request'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(
                        DateTime.parse(request['created_at']),
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Yargılama Giderleri ve Masraflar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconNeonButton(
                    onPressed: () {},
                    icon: Icons.print,
                    color: AppTheme.neonBlue,
                    size: 40,
                    tooltip: 'Yazdır',
                  ),
                  const SizedBox(width: 10),
                  NeonButton(
                    onPressed: () => _showAddExpenseDialog(),
                    label: 'Masraf Ekle',
                    icon: Icons.add,
                    color: AppTheme.neonOrange,
                    width: 150,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Expense categories
          Row(
            children: [
              Expanded(
                child: _buildExpenseTypeCard(
                  'Yargılama Giderleri',
                  Icons.gavel,
                  AppTheme.neonPurple,
                  0,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildExpenseTypeCard(
                  'Dosya Masrafları',
                  Icons.folder,
                  AppTheme.neonBlue,
                  0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTypeCard(String title, IconData icon, Color color, double total) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '${NumberFormat('#,###').format(total)} ₺',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Özel Kategoriler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              NeonButton(
                onPressed: () => _showAddCategoryDialog(),
                label: 'Kategori Ekle',
                icon: Icons.create_new_folder,
                color: AppTheme.neonGreen,
                width: 170,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildEmptyState(
            'Henüz özel kategori oluşturulmamış\nKategoriler oluşturarak dosyalarınızı düzenleyebilirsiniz',
            Icons.folder_special,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return FadeInUp(
      child: Center(
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog methods
  void _showAddPaymentDialog(Client client) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppTheme.cyanGradient,
              ),
              child: const Icon(Icons.payment, color: Colors.white),
            ),
            const SizedBox(width: 15),
            const Text('Yeni Ödeme', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedTextField(
                controller: amountController,
                label: 'Tutar (₺)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              AnimatedTextField(
                controller: descController,
                label: 'Açıklama',
                icon: Icons.description,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          NeonButton(
            onPressed: () async {
              if (amountController.text.isNotEmpty) {
                final payment = Payment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  clientId: client.id,
                  amount: double.parse(amountController.text),
                  paymentDate: DateTime.now(),
                  description: descController.text.isEmpty ? null : descController.text,
                  paymentType: 'payment',
                  isIncome: true,
                );
                await _dbService.addPayment(payment);
                Navigator.pop(context);
                _loadClientDetails();
              }
            },
            label: 'Ekle',
            icon: Icons.add,
            color: AppTheme.neonGreen,
            width: 100,
          ),
        ],
      ),
    );
  }

  void _showEditClientDialog(Client client) {
    final firstNameController = TextEditingController(text: client.firstName);
    final lastNameController = TextEditingController(text: client.lastName);
    final phoneController = TextEditingController(text: client.phoneNumber);
    final addressController = TextEditingController(text: client.address);
    final vasiNameController = TextEditingController(text: client.vasiName ?? '');
    final vasiPhoneController = TextEditingController(text: client.vasiPhone ?? '');
    final notesController = TextEditingController(text: client.notes ?? '');

    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.neonGreen.withOpacity(0.2),
                ),
                child: Icon(Icons.edit, color: AppTheme.neonGreen),
              ),
              const SizedBox(width: 15),
              const Text('Müvekkili Düzenle', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedTextField(
                    controller: firstNameController,
                    label: 'Ad',
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextField(
                    controller: lastNameController,
                    label: 'Soyad',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextField(
                    controller: phoneController,
                    label: 'Telefon',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextField(
                    controller: addressController,
                    label: 'Adres',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextField(
                    controller: vasiNameController,
                    label: 'Vasi',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextField(
                    controller: vasiPhoneController,
                    label: 'Vasi Telefon',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  AnimatedTextField(
                    controller: notesController,
                    label: 'Notlar',
                    icon: Icons.notes,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            NeonButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() => isSaving = true);
                      final updated = client.copyWith(
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        address: addressController.text.trim(),
                        vasiName: vasiNameController.text.trim().isEmpty
                            ? null
                            : vasiNameController.text.trim(),
                        vasiPhone: vasiPhoneController.text.trim().isEmpty
                            ? null
                            : vasiPhoneController.text.trim(),
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                        updatedAt: DateTime.now(),
                      );

                      final success = await _dbService.updateClient(updated);
                      if (!mounted) return;

                      if (success) {
                        Navigator.pop(context);
                        await _loadClientDetails();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Müvekkil bilgileri güncellendi'),
                            backgroundColor: AppTheme.neonGreen,
                          ),
                        );
                      } else {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Güncelleme sırasında hata oluştu'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              label: isSaving ? 'Kaydediliyor...' : 'Kaydet',
              icon: Icons.save,
              color: AppTheme.neonGreen,
              width: 140,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteClient(Client client) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red.withOpacity(0.15),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              ),
              const SizedBox(width: 15),
              const Text('Müvekkili Sil', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const SizedBox(
            width: 380,
            child: Text(
              'Bu işlem geri alınamaz. Müvekkili silmek istediğinize emin misiniz?',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            NeonButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      final success = await _dbService.deleteClient(client.id);
                      if (!mounted) return;

                      if (success) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Müvekkil silindi'),
                            backgroundColor: AppTheme.neonOrange,
                          ),
                        );
                      } else {
                        setDialogState(() => isDeleting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silme işlemi sırasında hata oluştu'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              label: isDeleting ? 'Siliniyor...' : 'Sil',
              icon: Icons.delete_forever,
              color: Colors.red,
              width: 110,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCommitmentDialog() {
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool hasAlarm = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppTheme.goldGradient,
                ),
                child: const Icon(Icons.schedule, color: Colors.white),
              ),
              const SizedBox(width: 15),
              const Text('Ödeme Taahhüdü', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedTextField(
                  controller: amountController,
                  label: 'Tutar (₺)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.cardColor,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.neonBlue),
                        const SizedBox(width: 15),
                        Text(
                          DateFormat('dd MMMM yyyy', 'tr').format(selectedDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Switch(
                      value: hasAlarm,
                      onChanged: (value) => setDialogState(() => hasAlarm = value),
                      activeColor: AppTheme.neonGreen,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hatırlatma kur',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            ),
            NeonButton(
              onPressed: () {
                Navigator.pop(context);
              },
              label: 'Ekle',
              icon: Icons.add,
              color: AppTheme.neonGreen,
              width: 100,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCourtDateDialog() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCourtDateScreen(),
        fullscreenDialog: true,
      ),
    );
    _loadClientDetails();
  }

  void _showAddRequestDialog() {
    final requestController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.neonGreen.withOpacity(0.2),
              ),
              child: Icon(Icons.assignment, color: AppTheme.neonGreen),
            ),
            const SizedBox(width: 15),
            const Text('Müvekkil Talebi', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: requestController,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Talep detaylarını yazın...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          NeonButton(
            onPressed: () async {
              if (requestController.text.isNotEmpty) {
                await _dbService.addClientRequest(
                  widget.clientData['id'],
                  requestController.text,
                );
                Navigator.pop(context);
                _loadClientDetails();
              }
            },
            label: 'Ekle',
            icon: Icons.add,
            color: AppTheme.neonGreen,
            width: 100,
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Masraf Ekle', style: TextStyle(color: Colors.white)),
        content: const SizedBox(
          width: 400,
          child: Text('Masraf ekleme formu', style: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppTheme.cyanGradient,
              ),
              child: const Icon(Icons.create_new_folder, color: Colors.white),
            ),
            const SizedBox(width: 15),
            const Text('Yeni Kategori', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: AnimatedTextField(
            controller: nameController,
            label: 'Kategori Adı',
            icon: Icons.folder,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          NeonButton(
            onPressed: () {
              Navigator.pop(context);
            },
            label: 'Oluştur',
            icon: Icons.add,
            color: AppTheme.neonGreen,
            width: 120,
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAddDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
    
    if (result != null) {
      // Handle file upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.files.first.name} dosyası eklendi'),
          backgroundColor: AppTheme.neonGreen,
        ),
      );
    }
  }

  Future<void> _printClientInfo(Client client) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'MÜVEKKİL BİLGİLERİ',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Ad Soyad: ${client.fullName}'),
            pw.Text('TC No: ${client.tcNo}'),
            pw.Text('Telefon: ${client.phoneNumber}'),
            pw.Text('Adres: ${client.address}'),
            pw.SizedBox(height: 20),
            pw.Text('Anlaşılan Tutar: ${NumberFormat('#,###').format(client.agreedAmount)} ₺'),
            pw.Text('Ödenen Tutar: ${NumberFormat('#,###').format(client.paidAmount)} ₺'),
            pw.Text('Kalan Tutar: ${NumberFormat('#,###').format(client.remainingAmount)} ₺'),
          ],
        ),
      ),
    );
    
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Future<void> _printPayments() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ÖDEME GEÇMİŞİ',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            ..._payments.map((payment) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(DateFormat('dd.MM.yyyy').format(payment.paymentDate)),
                  pw.Text(payment.description ?? 'Ödeme'),
                  pw.Text('${NumberFormat('#,###').format(payment.amount)} ₺'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
    
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
