import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'webview_screen.dart';
import 'tck_maddeleri_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/sidebar_menu.dart';
import 'client_detail_screen.dart';
import 'clients_screen.dart';
import 'add_client_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'logo_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  
  bool _isSearching = false;
  bool _showSearchResult = false;
  Map<String, dynamic>? _searchResult;
  String? _lastLogin;
  String? _lastLogout;
  
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  int _selectedMenuIndex = 0;
  
  int _clientCount = 0;
  int _upcomingCases = 0;
  int _pendingPayments = 0;
  int _totalRequests = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadLastLoginInfo();
    _loadStats();
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  Future<void> _loadLastLoginInfo() async {
    final info = await _authService.getLastLoginInfo();
    setState(() {
      _lastLogin = info['last_login'];
      _lastLogout = info['last_logout'];
    });
  }

  Future<void> _loadStats() async {
    final clients = await _dbService.getAllClients();
    final courtDates = await _dbService.getUpcomingCourtDates();
    final payments = await _dbService.getTodayPaymentCommitments();
    
    setState(() {
      _clientCount = clients.length;
      _upcomingCases = courtDates.length;
      _pendingPayments = payments.length;
      _totalRequests = 5; // Placeholder
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _showSearchResult = false;
    });

    final result = await _dbService.searchClientByTC(_searchController.text);
    
    setState(() {
      _isSearching = false;
      _searchResult = null;
      _showSearchResult = true;
    });

    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientDetailScreen(clientData: {"id": result.id, "tc_number": result.tcNo, "full_name": "${result.firstName} ${result.lastName}"}),
        ),
      );
    } else {
      _showNotFoundDialog();
    }
  }

  void _showNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bulunamadı', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bu TC kimlik numarasına sahip müvekkil bulunamadı.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: AppTheme.neonBlue)),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(int index) async {
    setState(() => _selectedMenuIndex = index);
    
    switch (index) {
      case 0: // Ana Sayfa
        break;
      case 1: // Müvekkiller
        final added = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => const ClientsScreen()),
        );
        if (added == true) {
          _loadStats();
        }
        break;
      case 2: // Duruşmalar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duruşmalar sayfası yakında eklenecek')),
        );
        break;
      case 3: // Ödemeler
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ödemeler sayfası yakında eklenecek')),
        );
        break;
      case 4: // TCK Maddeleri
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LogoMenuScreen()),
        );
        break;
      case 5: // Ayarlar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background with Particles
          _buildAnimatedBackground(),
          
          // Main Content
          Row(
            children: [
              // Sidebar
              SidebarMenu(
                selectedIndex: _selectedMenuIndex,
                onItemSelected: _handleMenuTap,
                onLogout: () async {
                  // Logout logic
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              ),
              
              // Main Content Area
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Top Bar
                    _buildTopBar(),
                    
                    // Main Dashboard
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Section
                            _buildWelcomeSection(),
                            
                            const SizedBox(height: 32),
                            
                            // Search Section
                            _buildSearchSection(),
                            
                            const SizedBox(height: 40),
                            
                            // Stats Grid
                            _buildStatsGrid(),
                            
                            const SizedBox(height: 40),
                            
                            // Quick Actions
                            _buildQuickActions(),
                            
                            const SizedBox(height: 40),
                            
                            // Recent Activity
                            _buildRecentActivity(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0E21),
                const Color(0xFF1a1f3a),
                Color.lerp(
                  const Color(0xFF1a1f3a),
                  AppTheme.neonPurple.withOpacity(0.1),
                  _pulseController.value,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: List.generate(20, (index) {
              final random = math.Random(index);
              final x = random.nextDouble();
              final y = (random.nextDouble() + _particleController.value) % 1;
              final size = random.nextDouble() * 4 + 2;
              
              return Positioned(
                left: MediaQuery.of(context).size.width * x,
                top: MediaQuery.of(context).size.height * y,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.neonBlue.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonBlue.withOpacity(0.5),
                        blurRadius: size * 2,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1f3a).withOpacity(0.7),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.neonBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              const Text(
                'Avukat Portal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Müvekkil Yönetim Sistemi',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Quick Action Buttons
              _buildQuickButton(Icons.home, 'E-Devlet', const Color(0xFFff4757)),
              const SizedBox(width: 8),
              _buildQuickButton(Icons.account_balance, 'UYAP', AppTheme.neonBlue),
              const SizedBox(width: 8),
              _buildQuickButton(Icons.attach_money, 'GİB', const Color(0xFF2ed573)),
              const SizedBox(width: 24),
              // Notifications
              _buildNotificationIcon(),
              const SizedBox(width: 16),
              // Settings
              IconButton(
                onPressed: () => _handleMenuTap(5),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, String label, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        ),
        if (_upcomingCases > 0 || _pendingPayments > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: const Color(0xFFff4757),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${_upcomingCases + _pendingPayments}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.neonPurple.withOpacity(0.2),
              AppTheme.neonBlue.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.neonBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar with Animation
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonBlue.withOpacity(_pulseController.value * 0.5),
                        blurRadius: 20 + (_pulseController.value * 10),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                );
              },
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Avukat Portalı',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppTheme.neonGreen),
                      const SizedBox(width: 8),
                      Text(
                        _lastLogin ?? 'İlk giriş',
                        style: TextStyle(
                          color: AppTheme.neonGreen.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2ed573).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2ed573)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: const Color(0xFF2ed573),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Aktif',
                    style: TextStyle(
                      color: const Color(0xFF2ed573),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1f3a).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.neonBlue.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: AppTheme.neonBlue, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Müvekkil Ara',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'TC Kimlik Numarası Girin...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.badge, color: AppTheme.neonBlue.withOpacity(0.5)),
                    ),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 56,
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonBlue.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isSearching ? null : _handleSearch,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: _isSearching
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Ara',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.3,
        children: [
          _buildStatCard(
            'Müvekkiller',
            _clientCount.toString(),
            Icons.people,
            AppTheme.neonBlue,
            const LinearGradient(colors: [Color(0xFF00d4ff), Color(0xFF0099ff)]),
          ),
          _buildStatCard(
            'Yaklaşan Duruşmalar',
            _upcomingCases.toString(),
            Icons.gavel,
            AppTheme.neonPurple,
            const LinearGradient(colors: [Color(0xFFb456ff), Color(0xFF7d2ae8)]),
          ),
          _buildStatCard(
            'Ödeme Bekleyen',
            _pendingPayments.toString(),
            Icons.payments,
            AppTheme.goldColor,
            const LinearGradient(colors: [Color(0xFFffa726), Color(0xFFff6f00)]),
          ),
          _buildStatCard(
            'Talepler',
            _totalRequests.toString(),
            Icons.request_page,
            const Color(0xFF2ed573),
            const LinearGradient(colors: [Color(0xFF00ff88), Color(0xFF00cc6a)]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    LinearGradient gradient,
  ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.02),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 + _pulseController.value * 0.2),
                  blurRadius: 20 + (_pulseController.value * 10),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 48, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı İşlemler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildQuickActionButton(
              'Yeni Müvekkil',
              Icons.person_add,
              AppTheme.neonGreen,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddClientScreen()),
              ),
            ),
            _buildQuickActionButton(
              'Hukuki Alanlar',
              Icons.gavel,
              AppTheme.neonPurple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogoMenuScreen()),
              ),
            ),
            _buildQuickActionButton(
              'TCK Maddeleri',
              Icons.menu_book,
              AppTheme.neonBlue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogoMenuScreen()),
              ),
            ),
            _buildQuickActionButton(
              'Ayarlar',
              Icons.settings,
              AppTheme.goldColor,
              () => _handleMenuTap(5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: 180,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1f3a).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neonBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son Aktiviteler',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildActivityItem(
            'Yeni müvekkil eklendi',
            '2 saat önce',
            Icons.person_add,
            const Color(0xFF2ed573),
          ),
          _buildActivityItem(
            'Duruşma tarihi güncellendi',
            '5 saat önce',
            Icons.event,
            AppTheme.neonBlue,
          ),
          _buildActivityItem(
            'Ödeme alındı',
            'Dün',
            Icons.payment,
            AppTheme.goldColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
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
    );
  }
}
