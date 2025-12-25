import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/neon_button.dart';
import '../widgets/animated_text_field.dart';
import 'home_screen.dart';
import 'account_creation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthService _authService = AuthService();
  
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  bool _isSecondPartyLogin = false;
  bool _useEmailLogin = false;
  bool _biometricAvailable = false;
  String? _lastLogin;
  String? _lastLogout;
  
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkBiometrics();
    _loadLastLoginInfo();
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

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _biometricAvailable = canCheckBiometrics && isDeviceSupported;
      });
    } catch (e) {
      print('Biyometrik kontrol hatası: $e');
    }
  }

  Future<void> _loadLastLoginInfo() async {
    final info = await _authService.getLastLoginInfo();
    setState(() {
      _lastLogin = info['last_login'];
      _lastLogout = info['last_logout'];
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      // Hesap oluşturuldu mı kontrol et
      final isAccountCreated = await _authService.isAccountCreated();
      if (!isAccountCreated) {
        _showError('⚠️ Biyometrik giriş kullanamaz! Lütfen SMS ile doğrulama yaparak önce hesap oluşturunuz.');
        return;
      }
      
      setState(() => _isLoading = true);
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Avukat Portal\'a giriş yapmak için doğrulayın',
      );
      
      if (authenticated) {
        await _authService.createLoginRecord('lawyer_id', 'biometric');
        _navigateToHome();
      }
    } on PlatformException catch (e) {
      _showError('Biyometrik doğrulama hatası: ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendSMSCode() async {
    if (_phoneController.text.isEmpty) {
      _showError('Lütfen telefon numaranızı girin');
      return;
    }
    
    setState(() => _isLoading = true);
    
    final success = await _authService.sendSMSCode(_phoneController.text);
    
    if (success) {
      setState(() {
        _codeSent = true;
        _resendCountdown = 60;
      });
      _startResendTimer();
      _showSuccess('Doğrulama kodu gönderildi');
    } else {
      _showError('Kod gönderilemedi. Lütfen tekrar deneyin.');
    }
    
    setState(() => _isLoading = false);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loginWithEmailPassword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Lütfen e-posta ve şifrenizi girin');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      print('🔐 E-posta giriş başlıyor: ${_emailController.text}');
      
      final result = await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      
      print('📋 Giriş sonucu: ${result['success']}');
      
      if (result['success'] == true) {
        print('✅ Giriş başarılı, home ekranına gidiliyor...');
        if (mounted) {
          await _authService.createLoginRecord('lawyer_id', 'email');
          _navigateToHome();
        }
      } else {
        print('❌ Giriş başarısız: ${result['error']}');
        _showError('Giriş başarısız: ${result['error'] ?? 'Bilinmeyen hata'}');
      }
    } catch (e) {
      print('❌ Giriş exception: $e');
      _showError('Giriş hatası: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifySMSCode() async {
    if (_codeController.text.isEmpty) {
      _showError('Lütfen doğrulama kodunu girin');
      return;
    }
    
    setState(() => _isLoading = true);
    
    final success = await _authService.verifySMSCode(
      _phoneController.text,
      _codeController.text,
    );
    
    if (success) {
      // Hesap oluşturuldu mı kontrol et
      final isAccountCreated = await _authService.isAccountCreated();
      
      if (_isSecondPartyLogin) {
        await _authService.createLoginRecord('second_party_id', 'second_party');
        _navigateToHome();
      } else {
        if (!isAccountCreated) {
          // İlk kez giriş yapan avukat - hesap oluşturmaya yönlendir
          _showSuccess('SMS Doğrulaması başarılı! Lütfen hesabınızı oluşturunuz.');
          await Future.delayed(const Duration(milliseconds: 800));
          _navigateToAccountCreation();
        } else {
          // Daha önceden hesap oluşturmuş
          await _authService.createLoginRecord('lawyer_id', 'sms');
          _navigateToHome();
        }
      }
    } else {
      _showError('Geçersiz doğrulama kodu');
    }
    
    setState(() => _isLoading = false);
  }

  void _navigateToAccountCreation() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AccountCreationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (Route<dynamic> route) => false, // Tüm önceki routes'ları sil
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _glowController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
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
                    const Color(0xFF0B1120),
                    const Color(0xFF1a1f36),
                    _backgroundController.value * 0.3,
                  )!,
                  const Color(0xFF0F1419),
                  Color.lerp(
                    const Color(0xFF0B1120),
                    const Color(0xFF1a2332),
                    _backgroundController.value * 0.2,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Subtle grid pattern
                CustomPaint(
                  size: size,
                  painter: GridPatternPainter(
                    animation: _backgroundController,
                  ),
                ),
                
                // Elegant floating orbs
                ...List.generate(12, (index) {
                  final offset = index * 0.2;
                  return Positioned(
                    left: (index * 120.0) % size.width,
                    top: (index * 100.0) % size.height,
                    child: AnimatedBuilder(
                      animation: _backgroundController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            cos((_backgroundController.value + offset) * 2 * pi) * 30,
                            sin((_backgroundController.value + offset) * 2 * pi) * 30,
                          ),
                          child: Opacity(
                            opacity: 0.15 + (sin((_backgroundController.value + offset) * pi) * 0.1),
                            child: Container(
                              width: 120 + (index % 4) * 40,
                              height: 120 + (index % 4) * 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    index % 2 == 0
                                        ? const Color(0xFF2196F3).withOpacity(0.2)
                                        : const Color(0xFF9C27B0).withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                
                // Main content
                child!,
              ],
            ),
          );
        },
        child: SafeArea(
          child: Row(
            children: [
              // Left side - Hero section
              Expanded(
                flex: 55,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated logo with modern design
                        FadeInLeft(
                          delay: const Duration(milliseconds: 200),
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF2196F3),
                                      const Color(0xFF1976D2),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2196F3).withOpacity(
                                        0.3 + (_glowController.value * 0.2),
                                      ),
                                      blurRadius: 30 + (_glowController.value * 10),
                                      spreadRadius: 0,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.balance,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Professional title
                        FadeInLeft(
                          delay: const Duration(milliseconds: 400),
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'AVUKAT',
                                  style: TextStyle(
                                    fontSize: 58,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                    height: 1.1,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: '\nPORTAL',
                                  style: TextStyle(
                                    fontSize: 58,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 6,
                                    height: 1.1,
                                    color: Color(0xFF90CAF9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        FadeInLeft(
                          delay: const Duration(milliseconds: 600),
                          child: Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        FadeInLeft(
                          delay: const Duration(milliseconds: 800),
                          child: Text(
                            'Profesyonel Hukuk Yönetimi',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        FadeInLeft(
                          delay: const Duration(milliseconds: 900),
                          child: Text(
                            'Modern teknoloji ile hukuki süreçlerinizi\nkontrol altında tutun. Her an, her yerde.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.5),
                              height: 1.7,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 70),
                        
                        // Premium features
                        ...List.generate(4, (index) {
                          final features = [
                            {
                              'icon': Icons.verified_user_outlined,
                              'title': 'Banka Seviyesi Güvenlik',
                              'desc': '256-bit SSL şifreleme',
                              'color': const Color(0xFF4CAF50)
                            },
                            {
                              'icon': Icons.cloud_outlined,
                              'title': 'Bulut Altyapısı',
                              'desc': 'Anlık senkronizasyon',
                              'color': const Color(0xFF2196F3)
                            },
                            {
                              'icon': Icons.analytics_outlined,
                              'title': 'Gelişmiş Analitik',
                              'desc': 'Detaylı raporlama',
                              'color': const Color(0xFF9C27B0)
                            },
                            {
                              'icon': Icons.support_agent_outlined,
                              'title': '7/24 Destek',
                              'desc': 'Uzman ekip desteği',
                              'color': const Color(0xFFFFC107)
                            },
                          ];
                          
                          return FadeInLeft(
                            delay: Duration(milliseconds: 1000 + (index * 150)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: (features[index]['color'] as Color).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (features[index]['color'] as Color).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      features[index]['icon'] as IconData,
                                      color: features[index]['color'] as Color,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          features[index]['title'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          features[index]['desc'] as String,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.4),
                                            fontSize: 13,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Right side - Login form
              Expanded(
                flex: 45,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 60),
                  child: Center(
                    child: SingleChildScrollView(
                      child: FadeInRight(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          padding: const EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a1f36).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              const Text(
                                'Hoş Geldiniz',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                'Devam etmek için giriş yapın',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 0.1,
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Login type toggle
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildLoginTypeButton(
                                        'Avukat',
                                        Icons.person_outline,
                                        !_isSecondPartyLogin,
                                        () => setState(() => _isSecondPartyLogin = false),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: _buildLoginTypeButton(
                                        'İkinci Taraf',
                                        Icons.group_outlined,
                                        _isSecondPartyLogin,
                                        () => setState(() => _isSecondPartyLogin = true),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Biometric login button (only for lawyer)
                              if (_biometricAvailable && !_isSecondPartyLogin) ...[
                                NeonButton(
                                  onPressed: _isLoading ? null : _authenticateWithBiometrics,
                                  icon: Icons.fingerprint,
                                  label: 'Biyometrik Giriş',
                                  color: AppTheme.neonGreen,
                                  width: double.infinity,
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 25),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'veya',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Login method toggle
                              if (!_isSecondPartyLogin) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () => setState(() => _useEmailLogin = false),
                                      child: Text(
                                        'Telefon',
                                        style: TextStyle(
                                          color: !_useEmailLogin ? AppTheme.neonBlue : Colors.white38,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '|',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => setState(() => _useEmailLogin = true),
                                      child: Text(
                                        'E-posta',
                                        style: TextStyle(
                                          color: _useEmailLogin ? AppTheme.neonBlue : Colors.white38,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                              
                              // Email/Password login
                              if (_useEmailLogin && !_isSecondPartyLogin) ...[
                                AnimatedTextField(
                                  controller: _emailController,
                                  label: 'E-posta',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  showEmailSuggestions: true,
                                ),
                                const SizedBox(height: 20),
                                AnimatedTextField(
                                  controller: _passwordController,
                                  label: 'Şifre',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                ),
                              ],
                              
                              // Phone login
                              if (!_useEmailLogin) ...[
                                AnimatedTextField(
                                  controller: _phoneController,
                                  label: 'Telefon Numarası',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  enabled: !_codeSent,
                                ),
                              ],
                              
                              if (_codeSent && !_useEmailLogin) ...[
                                const SizedBox(height: 20),
                                AnimatedTextField(
                                  controller: _codeController,
                                  label: 'Doğrulama Kodu',
                                  icon: Icons.lock_outline,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                )
                                    .animate()
                                    .fadeIn()
                                    .slideY(begin: -0.2, end: 0),
                              ],
                              
                              const SizedBox(height: 30),
                              
                              if (_useEmailLogin && !_isSecondPartyLogin)
                                NeonButton(
                                  onPressed: _isLoading ? null : _loginWithEmailPassword,
                                  icon: Icons.login,
                                  label: 'Giriş Yap',
                                  color: AppTheme.neonGreen,
                                  isLoading: _isLoading,
                                  width: double.infinity,
                                )
                              else if (!_codeSent)
                                Column(
                                  children: [
                                    NeonButton(
                                      onPressed: _isLoading ? null : _sendSMSCode,
                                      icon: Icons.sms,
                                      label: 'Kod Gönder',
                                      color: AppTheme.neonBlue,
                                      isLoading: _isLoading,
                                      width: double.infinity,
                                    ),
                                    const SizedBox(height: 20),
                                    // Sign up and forgot password links
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const AccountCreationScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Üye Ol',
                                            style: TextStyle(
                                              color: AppTheme.neonBlue,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Şifremi Unuttum özelliği yakında kullanılabilir'),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Şifremi Unuttum',
                                            style: TextStyle(
                                              color: Colors.orange[300],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    NeonButton(
                                      onPressed: _isLoading ? null : _verifySMSCode,
                                      icon: Icons.login,
                                      label: 'Giriş Yap',
                                      color: AppTheme.neonGreen,
                                      isLoading: _isLoading,
                                      width: double.infinity,
                                    ),
                                    const SizedBox(height: 15),
                                    TextButton(
                                      onPressed: _resendCountdown > 0
                                          ? null
                                          : () {
                                              setState(() => _codeSent = false);
                                              _codeController.clear();
                                            },
                                      child: Text(
                                        _resendCountdown > 0
                                            ? 'Tekrar gönder (${_resendCountdown}s)'
                                            : 'Farklı numara gir',
                                        style: TextStyle(
                                          color: _resendCountdown > 0
                                              ? Colors.white38
                                              : AppTheme.neonBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              
                              const SizedBox(height: 30),
                              
                              // Security info
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFF4CAF50),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        '256-bit SSL şifreleme ile\ntam koruma altındasınız',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.6),
                                          height: 1.5,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTypeButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2196F3),
                    Color(0xFF1976D2),
                  ],
                )
              : null,
          color: !isSelected ? Colors.transparent : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}

// Custom painter for grid pattern
class GridPatternPainter extends CustomPainter {
  final Animation<double> animation;
  
  GridPatternPainter({required this.animation}) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    const spacing = 50.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
