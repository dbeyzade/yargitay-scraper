import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/neon_button.dart';
import '../widgets/animated_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  
  List<SecondPartyUser> _secondPartyUsers = [];
  bool _isLoading = true;
  String _autoLockDuration = '30dk'; // Varsayılan değer
  
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSecondPartyUsers();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadSecondPartyUsers() async {
    final users = await _authService.getSecondPartyUsers('lawyer_id');
    setState(() {
      _secondPartyUsers = users;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSecuritySection(),
                      const SizedBox(height: 30),
                      _buildSecondPartySection(),
                      const SizedBox(height: 30),
                      _buildNotificationSection(),
                      const SizedBox(height: 30),
                      _buildAboutSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppTheme.goldColor, Colors.white],
                  ).createShader(bounds),
                  child: const Text(
                    'Ayarlar',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Uygulama ve güvenlik ayarları',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return FadeInUp(
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Güvenlik', Icons.security, AppTheme.neonGreen),
            const SizedBox(height: 25),
            
            _buildSettingItem(
              'Biyometrik Giriş',
              'Touch ID / Face ID ile giriş',
              Icons.fingerprint,
              AppTheme.neonGreen,
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.neonGreen,
              ),
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'SMS Doğrulama',
              'Her girişte SMS ile doğrulama',
              Icons.sms,
              AppTheme.neonBlue,
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.neonBlue,
              ),
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Şifre Değiştir',
              'Hesap şifrenizi güncelleyin',
              Icons.lock,
              AppTheme.neonPurple,
              onTap: () {
                // Change password
              },
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Telefon Numarası',
              'Kayıtlı telefon numaranızı değiştirin',
              Icons.phone,
              AppTheme.neonOrange,
              onTap: () {
                // Change phone
              },
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Otomatik Kilit',
              'Hareketsiz kaldıktan sonra ekranı kilitle: $_autoLockDuration',
              Icons.lock_clock,
              AppTheme.goldColor,
              onTap: () => _showAutoLockDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoLockDialog() {
    final options = [
      {'label': '5 Dakika', 'value': '5dk'},
      {'label': '10 Dakika', 'value': '10dk'},
      {'label': '30 Dakika', 'value': '30dk'},
      {'label': '1 Saat', 'value': '1 saat'},
      {'label': '2 Saat', 'value': '2 saat'},
      {'label': 'Asla', 'value': 'asla'},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1F3C),
                const Color(0xFF0A0E21),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.goldColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.goldColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.goldColor, AppTheme.goldColor.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Otomatik Kilit Süresi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Biyometrik giriş istenecek',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Options
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: options.map((option) {
                    final isSelected = _autoLockDuration == option['value'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _autoLockDuration = option['value'] as String;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Otomatik kilit süresi ${option['label']} olarak ayarlandı',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: AppTheme.goldColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.goldColor.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.goldColor
                                    : Colors.white.withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.goldColor
                                          : Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.goldColor,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  option['label'] as String,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.goldColor
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Close button
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'İptal',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
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

  Widget _buildSecondPartySection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('İkinci Taraf Erişimi', Icons.group, AppTheme.neonBlue),
                NeonButton(
                  onPressed: () => _showAddSecondPartyDialog(),
                  label: 'Ekle',
                  icon: Icons.person_add,
                  color: AppTheme.neonGreen,
                  width: 100,
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.neonBlue.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.neonBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.neonBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'İkinci taraf kullanıcıları uygulamaya SMS doğrulaması ile giriş yapabilir. '
                      'Sadece izin verdiğiniz kişiler erişebilir.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_secondPartyUsers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 50,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Henüz ikinci taraf kullanıcısı eklenmemiş',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _secondPartyUsers.length,
                itemBuilder: (context, index) {
                  return _buildSecondPartyUserCard(_secondPartyUsers[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondPartyUserCard(SecondPartyUser user, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: user.isActive
                ? AppTheme.neonGreen.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: user.isActive
                    ? AppTheme.cyanGradient
                    : AppTheme.glassGradient,
              ),
              child: Center(
                child: Text(
                  user.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.phoneNumber,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: user.isActive
                    ? AppTheme.neonGreen.withOpacity(0.2)
                    : Colors.redAccent.withOpacity(0.2),
              ),
              child: Text(
                user.isActive ? 'Aktif' : 'Pasif',
                style: TextStyle(
                  color: user.isActive ? AppTheme.neonGreen : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => _confirmDeactivateUser(user),
              icon: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
                color: user.isActive ? Colors.redAccent : AppTheme.neonGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Bildirimler', Icons.notifications, AppTheme.neonOrange),
            const SizedBox(height: 25),
            
            _buildSettingItem(
              'Ödeme Hatırlatmaları',
              'Taahhüt tarihlerinde bildirim al',
              Icons.payment,
              AppTheme.neonGreen,
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.neonGreen,
              ),
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Duruşma Hatırlatmaları',
              'Duruşmalardan önce bildirim al',
              Icons.gavel,
              AppTheme.neonPurple,
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.neonPurple,
              ),
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Giriş Bildirimleri',
              'Yeni giriş yapıldığında bildirim al',
              Icons.login,
              AppTheme.neonBlue,
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.neonBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Hakkında', Icons.info, AppTheme.goldColor),
            const SizedBox(height: 25),
            
            _buildSettingItem(
              'Sürüm',
              '1.0.0',
              Icons.new_releases,
              AppTheme.neonBlue,
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Gizlilik Politikası',
              'Gizlilik koşullarını görüntüle',
              Icons.privacy_tip,
              AppTheme.neonPurple,
              onTap: () {},
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Kullanım Şartları',
              'Kullanım koşullarını görüntüle',
              Icons.description,
              AppTheme.neonGreen,
              onTap: () {},
            ),
            
            const Divider(color: Colors.white12, height: 30),
            
            _buildSettingItem(
              'Destek',
              'Yardım ve destek alın',
              Icons.support_agent,
              AppTheme.neonOrange,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.2),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 15),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddSecondPartyDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
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
              child: const Icon(Icons.person_add, color: Colors.white),
            ),
            const SizedBox(width: 15),
            const Text(
              'İkinci Taraf Ekle',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedTextField(
                controller: nameController,
                label: 'Ad Soyad',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              AnimatedTextField(
                controller: phoneController,
                label: 'Telefon Numarası',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.neonOrange.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.neonOrange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: AppTheme.neonOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bu kişi uygulamaya SMS doğrulaması ile giriş yapabilecektir.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                await _authService.addSecondPartyUser(
                  'lawyer_id',
                  nameController.text,
                  phoneController.text,
                );
                Navigator.pop(context);
                _loadSecondPartyUsers();
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

  void _confirmDeactivateUser(SecondPartyUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              user.isActive ? Icons.block : Icons.check_circle,
              color: user.isActive ? Colors.redAccent : AppTheme.neonGreen,
            ),
            const SizedBox(width: 10),
            Text(
              user.isActive ? 'Erişimi Kaldır' : 'Erişimi Aktifleştir',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          user.isActive
              ? '${user.fullName} kullanıcısının erişimini kaldırmak istediğinize emin misiniz?'
              : '${user.fullName} kullanıcısının erişimini aktifleştirmek istediğinize emin misiniz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          NeonButton(
            onPressed: () async {
              await _authService.deactivateSecondPartyUser(user.id);
              Navigator.pop(context);
              _loadSecondPartyUsers();
            },
            label: user.isActive ? 'Kaldır' : 'Aktifleştir',
            color: user.isActive ? Colors.redAccent : AppTheme.neonGreen,
            width: 120,
          ),
        ],
      ),
    );
  }
}
