import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/neon_button.dart';
import '../widgets/animated_text_field.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final AuthService _authService = AuthService();
  
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _adresController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController(text: '+90');
  final _sifreController = TextEditingController();
  final _sifreDogrulamaController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _adresController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _sifreController.dispose();
    _sifreDogrulamaController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    // Validasyon
    if (_adController.text.isEmpty ||
        _soyadController.text.isEmpty ||
        _adresController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telefonController.text.isEmpty ||
        _sifreController.text.isEmpty ||
        _sifreDogrulamaController.text.isEmpty) {
      _showError('Lütfen tüm alanları doldurunuz');
      return;
    }

    // E-posta formatı kontrolü
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showError('Lütfen geçerli bir e-posta adresi girin');
      return;
    }

    if (_sifreController.text != _sifreDogrulamaController.text) {
      _showError('Şifreler eşleşmiyor');
      return;
    }

    if (_sifreController.text.length < 6) {
      _showError('Şifre en az 6 karakter olmalı');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📧 Hesap oluşturuluyor...');
      final signUpResult = await _authService.signUpWithEmail(
        _emailController.text,
        _sifreController.text,
        firstName: _adController.text,
        lastName: _soyadController.text,
        phone: _telefonController.text,
        address: _adresController.text,
      );
      
      print('📋 Sonuç: ${signUpResult['success']}');
      
      if (signUpResult['success'] == true) {
        if (mounted) {
          _showSuccess('Hesap başarıyla oluşturuldu! Ana sayfaya yönlendiriliyorsunuz...');
          await Future.delayed(const Duration(milliseconds: 1500));
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // Tüm önceki ekranları temizle
          );
        }
      } else {
        _showError('Hesap oluşturulamadı: ${signUpResult['error']}');
      }
    } catch (e) {
      _showError('Hata: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
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
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0B1120),
              const Color(0xFF0F1419),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Geri butonu
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Başlık
                  const Text(
                    'HESAP OLUŞTUR',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hukuk portalına hoş geldiniz',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Form
                  AnimatedTextField(
                    controller: _adController,
                    label: 'Ad',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  AnimatedTextField(
                    controller: _soyadController,
                    label: 'Soyadı',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  AnimatedTextField(
                    controller: _adresController,
                    label: 'Adres',
                    icon: Icons.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AnimatedTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    showEmailSuggestions: true,
                  ),
                  const SizedBox(height: 16),
                  AnimatedTextField(
                    controller: _telefonController,
                    label: 'Telefon Numarası',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AnimatedTextField(
                    controller: _sifreController,
                    label: 'Şifre',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  AnimatedTextField(
                    controller: _sifreDogrulamaController,
                    label: 'Şifre Doğrulama',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  
                  // Hesap Oluştur Butonu
                  NeonButton(
                    onPressed: _isLoading ? null : _createAccount,
                    label: 'Hesap Oluştur',
                    icon: Icons.check_circle,
                    color: AppTheme.neonGreen,
                    isLoading: _isLoading,
                    width: double.infinity,
                    height: 50,
                  ),
                  
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
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
                              color: Colors.white.withValues(alpha: 0.6),
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
    );
  }
}
