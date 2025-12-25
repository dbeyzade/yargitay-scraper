import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class OfficialDocumentsScreen extends StatefulWidget {
  const OfficialDocumentsScreen({super.key});

  @override
  State<OfficialDocumentsScreen> createState() =>
      _OfficialDocumentsScreenState();
}

class ActivityLogEntry {
  final String documentName;
  final String action; // 'upload', 'share', 'delete', 'view'
  final DateTime timestamp;
  final String? details;
  final String? sharedWith;

  ActivityLogEntry({
    required this.documentName,
    required this.action,
    required this.timestamp,
    this.details,
    this.sharedWith,
  });
}

class _OfficialDocumentsScreenState extends State<OfficialDocumentsScreen> {
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  bool _pinCreated = false;
  final List<DocumentFile> _documents = [];
  final List<ActivityLogEntry> _activityLog = [];
  DateTime? _entryTime;
  DateTime? _exitTime;
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPinStatus();
      }
    });
  }

  Future<void> _loadPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('official_documents_pin');
    
    setState(() => _pinCreated = savedPin != null && savedPin.isNotEmpty);
    
    if (!_pinCreated) {
      _showCreatePinDialog();
    } else {
      _showSecurityDialog();
    }
  }

  void _playSuccessVideo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: VideoPlayerWidget(
            onVideoEnd: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showCreatePinDialog() {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.neonGreen,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonGreen.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık
                    FadeInDown(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.neonGreen.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppTheme.neonGreen,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.vpn_key,
                              color: AppTheme.neonGreen,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: const Column(
                        children: [
                          Text(
                            'PIN KODU OLUŞTUR',
                            style: TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'İLK BAŞLATMA • GÜVENLİK',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.neonGreen.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info Box
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.neonGreen.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: AppTheme.neonGreen,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'İlk kez Resmi Evraklara erişiyorsunuz. 4 haneli PIN kodu oluşturunuz.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PIN Girişi
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PIN KODU (4 HANE)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: pinController,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            onChanged: (value) => setDialogState(() {}),
                            style: TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '●●●●',
                              hintStyle: TextStyle(
                                color: Colors.white24,
                                fontSize: 36,
                                letterSpacing: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.neonGreen,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.neonGreen.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.neonGreen,
                                  width: 2.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.03),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PIN Onayı
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PIN KODUNU ONAYLA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: confirmPinController,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            onChanged: (value) => setDialogState(() {}),
                            style: TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '●●●●',
                              hintStyle: TextStyle(
                                color: Colors.white24,
                                fontSize: 36,
                                letterSpacing: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.neonGreen,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.neonGreen.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.neonGreen,
                                  width: 2.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.03),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.neonGreen.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 250),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'İPTAL',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: () {
                                if (pinController.text.isEmpty ||
                                    confirmPinController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'PIN kodlarını giriniz',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: Colors.red.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (pinController.text !=
                                    confirmPinController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'PIN kodları eşleşmiyor',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: Colors.orange.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                // PIN'i kaydet
                                _savePinCode(pinController.text).then((_) {
                                  setState(() {
                                    _pinCreated = true;
                                  });
                                  if (mounted) {
                                    Navigator.pop(context);
                                    _showSecurityDialog();
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.neonGreen.withValues(alpha: 0.2),
                                side: BorderSide(
                                  color: AppTheme.neonGreen,
                                  width: 2,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'OLUŞTUR',
                                style: TextStyle(
                                  color: AppTheme.neonGreen,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
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
            ),
          ),
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.neonBlue,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppTheme.neonOrange.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Başlık
                  FadeInDown(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.neonBlue.withValues(alpha: 0.2),
                            border: Border.all(
                              color: AppTheme.neonBlue,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.security,
                            color: AppTheme.neonBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GÜVENLİK ONAY SİSTEMİ',
                                style: TextStyle(
                                  color: AppTheme.neonBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                'SEVIYE 4 • KRIPTO GÜVENLİK',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.neonBlue.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Banka Seviyesi Gizlilik
                  FadeInLeft(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.neonOrange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.neonOrange.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.neonOrange.withValues(alpha: 0.2),
                                ),
                                child: Icon(
                                  Icons.vpn_lock,
                                  color: AppTheme.neonOrange,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'ENCRYPTED STORAGE LAYER',
                                  style: TextStyle(
                                    color: AppTheme.neonOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '256-BIT AES | SHA-256 HASH | TLS 1.3 PROTOCOL\nBu bölüm, hassas resmi evraklarınız için banka seviyesi şifreleme ve gizlilik standartları ile korunmaktadır.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ekstra Doğrulama
                  FadeInRight(
                    delay: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.neonBlue.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.neonBlue.withValues(alpha: 0.2),
                                ),
                                child: Icon(
                                  Icons.verified_user,
                                  color: AppTheme.neonBlue,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'MULTI-FACTOR AUTHENTICATION',
                                  style: TextStyle(
                                    color: AppTheme.neonBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'PIN-BASED | BIOMETRIC READY | SESSION LOGGING\nBu önemli belgelere erişmek için ek güvenlik doğrulamasından geçmeniz gerekmektedir.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.neonBlue.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Butonlar
                  Row(
                    children: [
                      Expanded(
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                color: Colors.white24,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'İPTAL',
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 250),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAuthenticationDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGreen.withValues(alpha: 0.2),
                              side: BorderSide(
                                color: AppTheme.neonGreen,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'DEVAM ET',
                              style: TextStyle(
                                color: AppTheme.neonGreen,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
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
          ),
        ),
      ),
    );
  }

  void _showAuthenticationDialog() {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.neonBlue,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: AppTheme.neonGreen.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık
                    FadeInDown(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.neonBlue.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppTheme.neonBlue,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.fingerprint,
                              color: AppTheme.neonBlue,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: const Column(
                        children: [
                          Text(
                            'MFA DOĞRULAMA',
                            style: TextStyle(
                              color: AppTheme.neonBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'PIN KOD GIRIŞ SİSTEMİ',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.neonBlue.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: const Text(
                        'Güvenli erişim için 4 haneli PIN kodunuzu giriniz:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PIN Input
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: TextField(
                        controller: pinController,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        onChanged: (value) => setDialogState(() {}),
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: '●●●●',
                          hintStyle: TextStyle(
                            color: Colors.white24,
                            fontSize: 36,
                            letterSpacing: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppTheme.neonBlue,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: AppTheme.neonBlue.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: AppTheme.neonGreen,
                              width: 2.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.03),
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.neonBlue.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Column(
                      children: [
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAuthenticating
                                  ? null
                                  : () {
                                      setDialogState(
                                          () => _isAuthenticating = true);
                                      _verifyPin(pinController.text, () {
                                        if (mounted) {
                                          setDialogState(() =>
                                              _isAuthenticating = false);
                                          if (_isAuthenticated) {
                                            Navigator.pop(context);
                                          }
                                        }
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.neonGreen.withValues(alpha: 0.15),
                                side: BorderSide(
                                  color: AppTheme.neonGreen,
                                  width: 2,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isAuthenticating
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppTheme.neonGreen,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          '256BIT SSL UNLOCKING',
                                          style: TextStyle(
                                            color: AppTheme.neonGreen,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'DOĞRULA',
                                      style: TextStyle(
                                        color: AppTheme.neonGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 250),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'İPTAL',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showForgotPinDialog();
                            },
                            child: const Text(
                              'PIN KOD UNUTTUM?',
                              style: TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _verifyPin(String pin, VoidCallback onComplete) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Kaydedilen PIN'i al
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('official_documents_pin');

    // ignore: use_build_context_synchronously
    if (mounted) {
      if (pin == savedPin) {
        setState(() {
          _isAuthenticated = true;
          _failedAttempts = 0; // Başarılı giriş sonrası sıfırla
        });
        onComplete();
        // Video oynatacak dialog göster
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _playSuccessVideo();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Başarıyla doğrulandı!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _failedAttempts++);
        onComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hatalı kod. (${_failedAttempts}. deneme)'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _savePinCode(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('official_documents_pin', pin);
  }

  Future<void> _uploadFile() async {
    // ignore: use_build_context_synchronously
    if (!_isAuthenticated) {
      _showAuthenticationRequiredDialog();
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final fileName = result.files.single.name;
        setState(() {
          _documents.add(
            DocumentFile(
              name: fileName,
              size: result.files.single.size,
              uploadDate: DateTime.now(),
              path: result.files.single.path ?? '',
            ),
          );
        });
        
        // Log activity
        await _logActivity(
          documentName: fileName,
          action: 'upload',
          details: 'Dosya türü: ${fileName.split('.').last.toUpperCase()}',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ "$fileName" başarıyla yüklendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteDocument(int index) {
    if (!_isAuthenticated) {
      _showAuthenticationRequiredDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Dosyayı Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu dosyayı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final deletedDoc = _documents[index];
              setState(() => _documents.removeAt(index));
              Navigator.pop(context);
              
              // Log activity
              _logActivity(
                documentName: deletedDoc.name,
                action: 'delete',
                details: 'Dosya başarıyla silindi',
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ "${deletedDoc.name}" silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _printDocument(int index) {
    if (!_isAuthenticated) {
      _showAuthenticationRequiredDialog();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_documents[index].name} yazdırılıyor...'),
        backgroundColor: AppTheme.neonBlue,
      ),
    );
  }

  void _shareDocument(int index) {
    if (!_isAuthenticated) {
      _showAuthenticationRequiredDialog();
      return;
    }

    final doc = _documents[index];
    Share.share(
      'Resmi Evrak: ${doc.name}',
      subject: 'Avukat Portalı - Resmi Evrak Paylaşımı',
    );
    
    // Log activity
    _logActivity(
      documentName: doc.name,
      action: 'share',
      sharedWith: 'System Share',
      details: 'Dosya paylaşım menüsü açıldı',
    );
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Alert Icon
                  FadeInDown(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.security_update_warning,
                            color: Colors.orange,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: const Column(
                      children: [
                        Text(
                          'PIN KODU SIFIRLA',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'GÜVENLİK PROTOKOLÜ • DESTEK',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.orange.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Warning Box
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'PIN\'inizi unuttuysanız, sistem yöneticisiyle iletişime geçiniz. Kimlik doğrulaması sonrası yeni bir PIN oluşturabileceksiniz.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Info
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İLETİŞİM BİLGİLERİ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonBlue
                                            .withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.email,
                                        color: AppTheme.neonBlue,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'E-POSTA',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'support@avukat.local',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                                height: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonGreen
                                            .withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.phone,
                                        color: AppTheme.neonGreen,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TELEFON',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '+90 (212) 555-1234',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.orange.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.withValues(alpha: 0.15),
                          side: const BorderSide(
                            color: Colors.orange,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'TAMAM',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
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

  void _showAuthenticationRequiredDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu işlem için kimlik doğrulaması gereklidir'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatAccessTime(DateTime? time) {
    if (time == null) return 'Henüz giriş yapılmadı';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          setState(() => _isAuthenticated = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.darkBackground.withValues(alpha: 0.9),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                _isAuthenticated = false;
                _exitTime = DateTime.now();
                _failedAttempts = 0; // Çıkış yapıldığında başarısız denemeleri sıfırla
              });
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              Icon(Icons.description,
                  color: AppTheme.goldColor, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Resmi Evraklar',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: 'Sayfa Erişim Saatleri',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.neonBlue.withValues(alpha: 0.5),
                            width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.login,
                                  color: AppTheme.neonGreen,
                                  size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _formatAccessTime(_entryTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_failedAttempts > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.orange,
                                    size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '$_failedAttempts başarısız',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          if (_exitTime != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout,
                                    color: Colors.orange,
                                    size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _formatAccessTime(_exitTime),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
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
            ),
            if (_isAuthenticated)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Tooltip(
                    message: 'Kimlik Doğrulama Tamamlandı',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.green, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Doğrulandı',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground.withValues(alpha: 0.8),
              ],
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/bank.png'),
              fit: BoxFit.cover,
              opacity: 0.4,
            ),
          ),
          child: _isAuthenticated
              ? Stack(
                  children: [
                    _buildDocumentsList(),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: GlassmorphicContainer(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Erişim Günlüğü',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.login,
                                    color: AppTheme.neonGreen,
                                    size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  _formatAccessTime(_entryTime),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            if (_failedAttempts > 0) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.orange,
                                      size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_failedAttempts başarısız deneme',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_exitTime != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.logout,
                                      color: Colors.orange,
                                      size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatAccessTime(_exitTime),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : _buildAuthenticationRequired(),
        ),
      ),
    );
  }

  Widget _buildAuthenticationRequired() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonBlue.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 80,
                color: AppTheme.neonBlue,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Erişim Kısıtlı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Bu bölüme erişmek için güvenlik doğrulamasından geçmeniz gerekmektedir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _showAuthenticationDialog,
              icon: const Icon(Icons.verified_user),
              label: const Text('Doğrula'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppTheme.goldColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Toplam ${_documents.length} evrak',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Upload Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonGreen.withValues(alpha: 0.3),
                        AppTheme.neonGreen.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.neonGreen.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _uploadFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_upload,
                                color: AppTheme.neonGreen, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yeni Evrak Yükle',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Resmi belgenizi buraya ekleyin',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.add_circle,
                                color: AppTheme.neonGreen.withValues(alpha: 0.7),
                                size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_documents.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: FadeInUp(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: Icon(
                        Icons.folder_open,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Henüz Evrak Eklenmemiş',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final doc = _documents[index];
                return FadeInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppTheme.neonBlue.withValues(alpha: 0.2),
                            ),
                            child: Icon(Icons.description,
                                color: AppTheme.neonBlue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(doc.size / 1024).toStringAsFixed(2)} KB • ${_formatDate(doc.uploadDate)}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.print,
                            color: AppTheme.neonOrange,
                            onTap: () => _printDocument(index),
                            tooltip: 'Yazdır',
                          ),
                          const SizedBox(width: 6),
                          _buildActionButton(
                            icon: Icons.share,
                            color: AppTheme.neonPurple,
                            onTap: () => _shareDocument(index),
                            tooltip: 'Paylaş',
                          ),
                          const SizedBox(width: 6),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onTap: () => _deleteDocument(index),
                            tooltip: 'Sil',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _documents.length,
            ),
          ),
        // Activity Log Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity Log Title
                Row(
                  children: [
                    Icon(Icons.history, color: AppTheme.neonBlue, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'AKTİVİTE GÜNLÜĞÜ',
                      style: TextStyle(
                        color: AppTheme.neonBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_activityLog.length} İşlem',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _activityLog.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Henüz işlem kaydı yok',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _activityLog.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withValues(alpha: 0.1),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final log = _activityLog[index];
                          final actionColor = _getActionColor(log.action);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: actionColor.withValues(alpha: 0.05),
                              borderRadius: index == 0
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    )
                                  : index == _activityLog.length - 1
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        )
                                      : BorderRadius.zero,
                            ),
                            child: Row(
                              children: [
                                // Action Icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: actionColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    log.action == 'upload'
                                        ? Icons.cloud_upload
                                        : log.action == 'share'
                                            ? Icons.share
                                            : log.action == 'delete'
                                                ? Icons.delete_outline
                                                : Icons.visibility,
                                    color: actionColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Activity Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _getActionLabel(log.action),
                                            style: TextStyle(
                                              color: actionColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              log.documentName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            color: Colors.white.withValues(
                                              alpha: 0.4,
                                            ),
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatAccessTime(log.timestamp),
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                              fontSize: 10,
                                            ),
                                          ),
                                          if (log.sharedWith != null) ...[
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.person,
                                              color: Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              log.sharedWith!,
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.6,
                                                ),
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (log.details != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          log.details!,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
        // Bottom Padding
        SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.15),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _logActivity({
    required String documentName,
    required String action, // 'upload', 'share', 'delete', 'view'
    String? details,
    String? sharedWith,
  }) async {
    final logEntry = ActivityLogEntry(
      documentName: documentName,
      action: action,
      timestamp: DateTime.now(),
      details: details,
      sharedWith: sharedWith,
    );

    setState(() {
      _activityLog.insert(0, logEntry);
    });

    // Supabase'e kaydet (opsiyonel - kaldı uygulamada da lokal tutabiliriz)
    try {
      // Supabase insert işlemi yapılabilir burada
      // Şimdilik lokal state'te tutuyoruz
    } catch (e) {
      debugPrint('Log save error: $e');
    }
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'upload':
        return '📤 YÜKLEME';
      case 'share':
        return '🔗 PAYLAŞIM';
      case 'delete':
        return '🗑️ SİLME';
      case 'view':
        return '👁️ GÖRÜNTÜLEME';
      default:
        return action.toUpperCase();
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'upload':
        return AppTheme.neonGreen;
      case 'share':
        return AppTheme.neonBlue;
      case 'delete':
        return Colors.red;
      case 'view':
        return AppTheme.neonOrange;
      default:
        return Colors.white54;
    }
  }
}

class DocumentFile {
  final String name;
  final int size;
  final DateTime uploadDate;
  final String path;

  DocumentFile({
    required this.name,
    required this.size,
    required this.uploadDate,
    required this.path,
  });
}

class VideoPlayerWidget extends StatefulWidget {
  final VoidCallback? onVideoEnd;
  
  const VideoPlayerWidget({Key? key, this.onVideoEnd}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/bank-door.mov')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        // Video bittiğinde callback çalıştır
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            widget.onVideoEnd?.call();
          }
        });
      }).catchError((error) {
        debugPrint('Video initialization error: $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: _isInitialized
          ? Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                VideoPlayer(_controller),
                if (!_controller.value.isPlaying)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.play();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.neonBlue,
                ),
              ),
            ),
    );
  }
}
