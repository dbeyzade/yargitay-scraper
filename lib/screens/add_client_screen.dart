import 'dart:math' as Math;
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/client_model.dart';
import '../services/database_service.dart';
import '../services/native_ocr_service.dart';
import '../services/auth_service.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/neon_button.dart';
import '../widgets/animated_text_field.dart';

// Sadece harf ve Türkçe karakterler için input formatter
class LettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^a-zA-ZğüşıöçĞÜŞİÖÇ\s]'), '');
    return TextEditingValue(
      text: filtered.toUpperCase(),
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

// Sadece rakamlar için input formatter
class NumbersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

// Para birimi formatlayıcı (Binlik ayraçlı)
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Sadece rakamları al
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanText.isEmpty) {
       return newValue.copyWith(text: '');
    }

    // Sayıya çevir ve formatla
    double value = double.parse(cleanText);
    final formatter = NumberFormat('#,###', 'tr_TR');
    String newText = formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

const String _facingFront = 'front';
const String _facingBack = 'back';

class AddClientScreen extends StatefulWidget {
  final String? initialTcNo;
  final bool isFirstTimeSetup;

  const AddClientScreen({super.key, this.initialTcNo, this.isFirstTimeSetup = false});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen>
    with TickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _tcController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _vasiNameController = TextEditingController();
  final _vasiPhoneController = TextEditingController();
  final _agreedAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _idSerialController = TextEditingController();
  final _idValidUntilController = TextEditingController();


  File? _selectedPhoto;
  bool _isLoading = false;
  bool _isScanning = false;
  
  // Ödeme türü ve taksit bilgileri
  bool _paymentNakit = false;
  bool _paymentCek = false;
  bool _paymentHavale = false;
  bool _paymentTaksit = false;
  int _taksitSayisi = 1;
  final _taksitMiktariController = TextEditingController();

  // Çek bilgileri
  final _cekVadeTarihiController = TextEditingController();
  final _cekFaizOraniController = TextEditingController();
  final _cekSahibiController = TextEditingController();
  bool _cekHamiline = false;

  late AnimationController _backgroundController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.initialTcNo != null) {
      _tcController.text = widget.initialTcNo!;
    }
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _scanController.dispose();
    _tcController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _vasiNameController.dispose();
    _vasiPhoneController.dispose();
    _agreedAmountController.dispose();
    _paidAmountController.dispose();
    _taksitMiktariController.dispose();
    _cekVadeTarihiController.dispose();
    _cekFaizOraniController.dispose();
    _cekSahibiController.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _motherNameController.dispose();
    _fatherNameController.dispose();
    _idSerialController.dispose();
    _idValidUntilController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(BuildContext anchorContext) async {
    final selection = await _showPhotoPickerMenu(anchorContext);

    switch (selection) {
      case 'gallery':
        await _scanFromGallery();
        break;
      case 'front':
        await _openCameraScanner(facing: _facingBack);
        break;
      case 'back':
        await _openCameraScanner(facing: _facingBack);
        break;
      default:
        return;
    }
  }

  Future<String?> _showPhotoPickerMenu(BuildContext anchorContext) {
    final renderBox = anchorContext.findRenderObject() as RenderBox?;
    final origin = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? const Size(0, 0);

    return showMenu<String>(
      context: context,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(
        origin.dx,
        origin.dy + size.height,
        origin.dx + size.width,
        origin.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library, color: AppTheme.neonBlue),
              const SizedBox(width: 8),
              const Text('Galeriden ekle'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'back',
          child: Row(
            children: [
              Icon(Icons.camera_rear, color: AppTheme.neonPurple),
              const SizedBox(width: 10),
              const Text('Arka kamera'),
            ],
          ),
        ),
      ],
    );
  }

  void _showScanOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.document_scanner, color: AppTheme.goldColor),
            const SizedBox(width: 10),
            const Text(
              'Kimlik Tarama',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kimlik kartınızı taramak için bir yöntem seçin:',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    color: AppTheme.neonGreen,
                    onTap: () {
                      Navigator.pop(context);
                      _openCameraScanner();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    color: AppTheme.neonBlue,
                    onTap: () {
                      Navigator.pop(context);
                      _scanFromGallery();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCameraScanner({String facing = _facingBack}) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScannerScreen(preferredFacing: facing),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _selectedPhoto = File(result));
      await _processIdCardImage(result);
    }
  }

  Future<void> _scanFromGallery() async {
    setState(() => _isScanning = true);
    _scanController.repeat();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        dialogTitle: 'Kimlik Kartı Resmi Seçin',
      );

      if (result != null && result.files.single.path != null) {
        final imagePath = result.files.single.path!;
        setState(() => _selectedPhoto = File(imagePath));
        await _processIdCardImage(imagePath);
      }
    } catch (e) {
      _showError('Tarama hatası: $e');
    } finally {
      setState(() => _isScanning = false);
      _scanController.stop();
      _scanController.reset();
    }
  }
  
  Future<void> _processIdCardImage(String imagePath) async {
    setState(() => _isScanning = true);
    _scanController.repeat();

    try {
      // OCR ile metin tanıma (Doğrudan orijinal görüntüyü kullan)
      // Preprocessing bazen kaliteyi düşürebilir, bu yüzden doğrudan deniyoruz.
      final recognizedText = await NativeOcrService.recognizeText(imagePath);
      _parseIdCardText(recognizedText);
      
      // Kimlik kartındaki fotoğrafı çıkar
      await _extractIdCardPhoto(imagePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(child: Text('Kimlik bilgileri başarıyla okundu!')),
              ],
            ),
            backgroundColor: AppTheme.neonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _showError('OCR hatası: $e');
    } finally {
      setState(() => _isScanning = false);
      _scanController.stop();
      _scanController.reset();
    }
  }

  Future<String> _prepareIdImageForOcr(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return imagePath;

      // Dikey çekilmişse yataya çevir (kimlik kartı yataydır)
      if (image.height > image.width) {
        image = img.copyRotate(image, angle: 90);
      }

      // Hafif keskinleştirme + kontrast/aydınlık artışı
      image = img.grayscale(image);
      image = img.adjustColor(
        image,
        contrast: 1.25,
        brightness: 0.04,
        saturation: 1.05,
        gamma: 1.0,
      );

      final tempDir = await getTemporaryDirectory();
      final processed = File('${tempDir.path}/id_ocr_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await processed.writeAsBytes(img.encodeJpg(image, quality: 95));
      return processed.path;
    } catch (_) {
      return imagePath;
    }
  }
  
  Future<void> _extractIdCardPhoto(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) return;
      
      // Gönderilen kimlik kartı fotoğrafına göre:
      // Vesikalık fotoğraf sol tarafta, TC numarasının altında
      // Türk kimlik kartı oranları: yaklaşık 85.6mm x 54mm (kredi kartı boyutu)
      // Fotoğraf: sol kenardan ~6-8%, üstten ~18-22%, genişlik ~24-26%, yükseklik ~60%
      
      final imageWidth = originalImage.width;
      final imageHeight = originalImage.height;
      
      // Vesikalık fotoğraf koordinatları (kimlik kartı görüntüsünden)
      // Sol kenardan %07, üstten %23 başlıyor (Daha aşağıdan başlayarak kafayı yukarı taşıyoruz)
      // Genişlik: %25, Yükseklik: %65 (Çeneyi almak için yükseklik artırıldı)
      final photoX = (imageWidth * 0.07).toInt();
      final photoY = (imageHeight * 0.23).toInt();
      final photoWidth = (imageWidth * 0.25).toInt();
      final photoHeight = (imageHeight * 0.65).toInt();
      
      print('Görüntü boyutu: ${imageWidth}x${imageHeight}');
      print('Fotoğraf bölgesi: x=$photoX, y=$photoY, w=$photoWidth, h=$photoHeight');
      
      // Fotoğrafı kırp
      final croppedPhoto = img.copyCrop(
        originalImage,
        x: photoX.clamp(0, imageWidth - photoWidth),
        y: photoY.clamp(0, imageHeight - photoHeight),
        width: photoWidth.clamp(1, imageWidth - photoX),
        height: photoHeight.clamp(1, imageHeight - photoY),
      );
      
      // Kaydet
      final tempDir = await getTemporaryDirectory();
      final photoFile = File('${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await photoFile.writeAsBytes(img.encodeJpg(croppedPhoto, quality: 95));
      
      setState(() {
        _selectedPhoto = photoFile;
      });
      
      print('✓ Kimlik fotoğrafı çıkarıldı: ${photoFile.path}');
    } catch (e) {
      print('Fotoğraf çıkarma hatası: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
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
  }

  void _parseIdCardText(String text) {
    print('========== OCR Ham Metin ==========');
    print(text);
    print('====================================');

    // Tüm metni satırlara böl
    final lines = text
      .split('\n')
      .map((e) => _cleanOcrArtifacts(e.trim()))
      .where((e) => e.isNotEmpty)
      .toList();
    
    for (int i = 0; i < lines.length; i++) {
      print('  [$i] ${lines[i]}');
    }

    // 1. TC Kimlik No (11 haneli sayı)
    // Allow spaces between digits
    final tcRegex = RegExp(r'[1-9]\s*(?:\d\s*){10}');
    final tcMatch = tcRegex.firstMatch(text);
    if (tcMatch != null) {
      // Remove spaces for the controller
      _tcController.text = tcMatch.group(0)!.replaceAll(RegExp(r'\s+'), '');
      print('✓ TC Bulundu: ${_tcController.text}');
    }

    // 2. Tarihler (Doğum ve Geçerlilik)
    // DD.MM.YYYY veya DD/MM/YYYY formatı, boşluklara izin ver
    final dateRegex = RegExp(r'(\d{2})\s*[./]\s*(\d{2})\s*[./]\s*(\d{4})');
    final dates = dateRegex.allMatches(text).map((m) {
      // Clean up spaces in the date string
      return '${m.group(1)}.${m.group(2)}.${m.group(3)}';
    }).toList();
    
    if (dates.isNotEmpty) {
      // Tarihleri yıllarına göre sırala
      dates.sort((a, b) {
        final yearA = int.parse(a.split('.').last);
        final yearB = int.parse(b.split('.').last);
        return yearA.compareTo(yearB);
      });

      // En eski tarih genellikle doğum tarihidir
      _birthDateController.text = dates.first;
      print('✓ Doğum Tarihi: ${_birthDateController.text}');

      // En yeni tarih (eğer gelecekteyse) son geçerlilik tarihidir
      if (dates.length > 1) {
        final lastDate = dates.last;
        final year = int.parse(lastDate.split('.').last);
        if (year > DateTime.now().year) {
          _idValidUntilController.text = lastDate;
          print('✓ Son Geçerlilik: ${_idValidUntilController.text}');
        }
      }
    }

    // 3. Seri No (Document No)
    // Genellikle 9 karakterli, harf ve rakam karışık (Örn: A14M21219)
    final serialRegex = RegExp(r'\b[A-Z0-9]{9}\b');
    final potentialSerials = serialRegex.allMatches(text)
        .map((m) => m.group(0)!)
        .where((s) => RegExp(r'[A-Z]').hasMatch(s) && RegExp(r'[0-9]').hasMatch(s)) // Hem harf hem rakam içermeli
        .toList();
    
    if (potentialSerials.isNotEmpty) {
      _idSerialController.text = potentialSerials.first;
      print('✓ Seri No: ${_idSerialController.text}');
    }

    // 4. İsim ve Soyisim
    String? surname;
    String? givenName;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      // Soyadı bulma
      if (surname == null && (lineLower.contains('soyad') || lineLower.contains('surname') || lineLower.startsWith('sur') || lineLower.startsWith('soy'))) {
        // Aynı satırda olabilir mi? Genellikle alt satırdadır ama kontrol edelim
        String cleanLine = line.replaceAll(RegExp(r'soyad|surname|suramo|surame|soy|:|', caseSensitive: false), '').trim();
        if (_isValidName(cleanLine) && !_isCommonWord(cleanLine)) {
          surname = cleanLine;
        } else {
          // Alt satıra bak
          final candidate = _nextName(lines, i + 1);
          if (candidate != null) surname = candidate;
        }
      }

      // Adı bulma
      if (givenName == null && (lineLower.contains('adı') || lineLower.contains('given') || lineLower.contains('name'))) {
        String cleanLine = line.replaceAll(RegExp(r'adı|given|name|\(s\)|:|', caseSensitive: false), '').trim();
        if (_isValidName(cleanLine) && !_isCommonWord(cleanLine)) {
           if (surname == null || cleanLine != surname) {
             givenName = cleanLine;
           }
        } else {
          // Alt satıra bak
          final candidate = _nextName(lines, i + 1, exclude: surname);
          if (candidate != null) givenName = candidate;
        }
      }
    }
    
    // Etiketlerle bulunamadıysa alternatif yöntem (Büyük harfli kelimeler)
    if (surname == null || givenName == null) {
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Tek kelimelik, tamamen büyük harf, en az 2 karakter
        if (RegExp(r'^[A-ZĞÜŞİÖÇ]+$').hasMatch(line) && line.length >= 2 && !_isCommonWord(line) && !_isLabelLine(line)) {
          // Genellikle Soyad üstte veya sonda olabilir, ama basitçe sırayla atayalım
          // Eğer TC'den sonra geliyorsa isim olma ihtimali yüksek
          final candidate = _normalizeName(line);
          
          if (surname == null) {
            surname = candidate;
          } else if (givenName == null) {
            // Eğer bulunan kelime soyad ile aynıysa ve aralarında çok mesafe yoksa muhtemelen aynı kelimedir
            if (candidate != surname) {
              givenName = candidate;
            }
          }
        }
      }
    }
    
    if (surname != null) {
      _lastNameController.text = surname;
      print('✓ Soyad: $surname');
    }
    if (givenName != null) {
      _firstNameController.text = givenName;
      print('✓ Ad: $givenName');
    }

    setState(() {});
    
    // Eğer hiçbir şey bulunamadıysa kullanıcıya ham metni göster
    if (_tcController.text.isEmpty && _firstNameController.text.isEmpty && _lastNameController.text.isEmpty) {
      _showRawTextDialog(text);
    }
  }

  void _showRawTextDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('OCR Sonucu', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Otomatik ayrıştırma yapılamadı. Okunan metin:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(text, style: const TextStyle(color: Colors.white, fontFamily: 'Courier')),
              ),
            ],
          ),
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
  
  bool _isValidName(String text) {
    // Sadece harfler, Türkçe karakterler ve boşluk içermeli
    return RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$').hasMatch(text) && text.length >= 2;
  }

  String? _nextName(List<String> lines, int startIndex, {String? exclude}) {
    if (startIndex >= lines.length) return null;
    for (int j = startIndex; j < lines.length && j < startIndex + 3; j++) {
      final candidate = lines[j].trim();
      if (_isValidName(candidate) && !_isLabelLine(candidate)) {
        final normalized = _normalizeName(candidate);
        if (exclude != null && normalized == exclude) continue;
        return normalized;
      }
    }
    return null;
  }

  String _cleanOcrArtifacts(String raw) {
    var t = raw
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll(RegExp(r'[^A-Za-z0-9ğüşıöçĞÜŞİÖÇ\.\-\s]'), '');
    return t.trim();
  }

  String _normalizeName(String raw) {
    var name = raw.toUpperCase();
    const replacements = {
      '0': 'O',
      '1': 'I',
      '5': 'S',
      '8': 'B',
      '6': 'G',
      '4': 'A',
    };

    replacements.forEach((k, v) {
      name = name.replaceAll(k, v);
    });

    // Özel sık hatalar: DOĞUKAN gibi isimler başı B/D karışabiliyor
    if (name.startsWith('B') && name.contains('OGU')) {
      name = 'D' + name.substring(1);
    }

    // Çift boşlukları temizle
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    return name;
  }
  
  bool _isLabelLine(String text) {
    final lower = text.toLowerCase();
    // Check if the line is JUST a label or contains label keywords strongly
    // Also check for common OCR misreads of labels
    return lower.contains('surname') || 
           lower.contains('soyad') || 
           lower.contains('name') || 
           lower.contains('adı') ||
           lower.contains('given') ||
           lower.contains('birth') ||
           lower.contains('doğum') ||
           lower.contains('gender') ||
           lower.contains('cinsiyet') ||
           lower.contains('nationality') ||
           lower.contains('uyruk') ||
           lower.contains('valid') ||
           lower.contains('geçerli') ||
           lower.contains('document') ||
           lower.contains('seri') ||
           lower.contains('republic') ||
           lower.contains('türkiye') ||
           lower.contains('kimlik') ||
           lower.contains('identity') ||
           lower.contains('card') ||
           // Common OCR misreads for labels
           lower.startsWith('sur') || // Surname
           lower.startsWith('soy') || // Soyadı
           lower.startsWith('giv') || // Given
           lower.startsWith('nam') || // Name
           lower.startsWith('adi');   // Adı
  }
  
  bool _isCommonWord(String text) {
    final upper = text.toUpperCase();
    final common = ['TÜRKİYE', 'CUMHURİYETİ', 'KİMLİK', 'KARTI', 'REPUBLIC', 'TURKEY', 
                    'IDENTITY', 'CARD', 'SURNAME', 'NAME', 'DATE', 'BIRTH', 'GENDER',
                    'NATIONALITY', 'VALID', 'UNTIL', 'DOCUMENT', 'NO', 'TR',
                    'SOYADI', 'ADI', 'GIVEN', 'NAMES', 'SERI', 'UYRUK', 'CINSIYET',
                    'SURAMO', 'SOY', 'NAM', 'GIV', 'SUR', 'SURAME']; // Add observed misreads
    
    if (common.contains(upper)) return true;
    
    // Check if any word in the text is a common word
    final words = upper.split(' ');
    for (final word in words) {
      if (common.contains(word)) return true;
    }
    
    return false;
  }


  Future<void> _saveClient() async {
    print('🔵 Kaydet butonuna basıldı');
    
    // Temel alanları kontrol et
    if (_tcController.text.isEmpty || _tcController.text.length != 11) {
      _showError('Lütfen geçerli bir TC Kimlik No giriniz (11 haneli)');
      return;
    }
    
    if (_firstNameController.text.isEmpty) {
      _showError('Lütfen ad giriniz');
      return;
    }
    
    if (_lastNameController.text.isEmpty) {
      _showError('Lütfen soyad giriniz');
      return;
    }
    
    if (_phoneController.text.isEmpty) {
      _showError('Lütfen telefon numarası giriniz');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showError('Lütfen adres giriniz');
      return;
    }

    print('✅ Tüm alanlar dolu, müvekkil kaydediliyor...');
    setState(() => _isLoading = true);

    try {
      final client = Client(
        id: const Uuid().v4(),
        tcNo: _tcController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        vasiName: _vasiNameController.text.isEmpty ? null : _vasiNameController.text,
        vasiPhone: _vasiPhoneController.text.isEmpty ? null : _vasiPhoneController.text,
        agreedAmount: double.tryParse(_agreedAmountController.text.replaceAll('.', '')) ?? 0,
        paidAmount: double.tryParse(_paidAmountController.text.replaceAll('.', '')) ?? 0,
        debt: 0,
        createdAt: DateTime.now(),
        birthDate: _birthDateController.text.isEmpty ? null : _birthDateController.text,
        birthPlace: _birthPlaceController.text.isEmpty ? null : _birthPlaceController.text,
        motherName: _motherNameController.text.isEmpty ? null : _motherNameController.text,
        fatherName: _fatherNameController.text.isEmpty ? null : _fatherNameController.text,
      );

      print('🔄 Veritabanına ekleniyor...');
      final result = await _dbService.addClient(client);
      print('✅ Veritabanından sonuç: ${result != null ? "Başarılı" : "Başarısız"}');

      if (mounted && result != null) {
        // İlk hesap oluşturuldu bayrağını set et
        await _authService.setAccountCreated(true);
        Navigator.pop(context, result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                const Text('Müvekkil başarıyla eklendi'),
              ],
            ),
            backgroundColor: AppTheme.neonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _showError('Hata: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFirstTimeSetup ? 'Hesap Oluştur' : 'Yeni Müvekkil Ekle',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isFirstTimeSetup)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.15),
                      border: Border.all(
                        color: const Color(0xFF2ECC71).withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '✓ Hesabınızı oluşturmak için lütfen aşağıya ilk müvekkil bilgilerinizi girin.',
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                _buildIdScanSection(),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildIdentityCardSection()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildContactSection()),
                  ],
                ),
                const SizedBox(height: 20),
                _buildVasiSection(),
                const SizedBox(height: 20),
                _buildFinancialSection(),
                const SizedBox(height: 30),
                Center(
                  child: NeonButton(
                    onPressed: _isLoading ? null : _saveClient,
                    label: widget.isFirstTimeSetup ? 'Hesap Oluştur' : 'Müvekkil Kaydet',
                    icon: Icons.save,
                    color: AppTheme.neonGreen,
                    isLoading: _isLoading,
                    width: 250,
                    height: 60,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: FadeInDown(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                ).createShader(bounds),
                child: const Text(
                  'Yeni Müvekkil Ekle',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdScanSection() {
    return FadeInUp(
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.neonGlow(AppTheme.goldColor, blur: 15, spread: 1),
              ),
              child: const Icon(Icons.document_scanner, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kimlik Tarama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamera veya galeriden kimlik kartı tarayın',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            _buildScanVisual(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanVisual() {
    return SizedBox(
      width: 200,
      height: 64,
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, _) {
          final t = _backgroundController.value;
          final animAlign = -1.0 + (t * 2.0);
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonBlue.withValues(alpha: 0.22),
                      AppTheme.neonPurple.withValues(alpha: 0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.55)),
                  boxShadow: AppTheme.neonGlow(AppTheme.neonBlue, blur: 14, spread: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.neonBlue.withValues(alpha: 0.12),
                        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.6)),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: AppTheme.neonBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isScanning ? 'Taranıyor...' : 'Otomatik tarama',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment(animAlign, 0),
                    child: Container(
                      width: 16,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.02),
                            AppTheme.neonBlue.withValues(alpha: 0.5),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIdentityCardSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GlassmorphicContainer(
          padding: const EdgeInsets.all(4),
          borderRadius: 12,
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(
                        'assets/images/yildiz.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.badge, color: AppTheme.neonBlue, size: 20),
                          const SizedBox(width: 10),
                          const Text(
                            'T.C. Kimlik Kartı',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.35)),
                        ),
                        child: const Text(
                          'RESMI BELGE',
                          style: TextStyle(letterSpacing: 1.1, fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoCard(),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedTextField(
                          controller: _tcController,
                          label: 'T.C. Kimlik No / TR Identity No',
                          icon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          inputFormatters: [NumbersOnlyFormatter()],
                        ),
                        const SizedBox(height: 12),
                        AnimatedTextField(
                          controller: _lastNameController,
                          label: 'Soyadı / Surname',
                          icon: Icons.person_outline,
                          inputFormatters: [LettersOnlyFormatter()],
                        ),
                        const SizedBox(height: 12),
                        AnimatedTextField(
                          controller: _firstNameController,
                          label: 'Adı / Given Name(s)',
                          icon: Icons.person,
                          inputFormatters: [LettersOnlyFormatter()],
                        ),
                        const SizedBox(height: 12),
                        AnimatedTextField(
                          controller: _birthDateController,
                          label: 'Doğum Tarihi / Date of Birth',
                          icon: Icons.cake,
                          keyboardType: TextInputType.datetime,
                        ),
                        const SizedBox(height: 12),
                        AnimatedTextField(
                          controller: _idSerialController,
                          label: 'Seri No / Document No',
                          icon: Icons.confirmation_number,
                        ),
                        const SizedBox(height: 12),
                        AnimatedTextField(
                          controller: _idValidUntilController,
                          label: 'Son Geçerlilik / Valid Until',
                          icon: Icons.event_available,
                          keyboardType: TextInputType.datetime,
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

  Widget _buildPhotoCard() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _pickPhoto(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 148,
              height: 176,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPhoto != null
                      ? AppTheme.neonGreen
                      : AppTheme.neonBlue.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: _selectedPhoto != null
                    ? AppTheme.neonGlow(AppTheme.neonGreen, blur: 10, spread: 1)
                    : null,
                image: _selectedPhoto != null
                    ? DecorationImage(
                        image: FileImage(_selectedPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedPhoto == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 32, color: Colors.white.withValues(alpha: 0.55)),
                        const SizedBox(height: 0),
                        Text('Fotoğraf Ekle', style: TextStyle(color: Colors.white.withValues(alpha: 0.55))),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 0),
          NeonButton(
            onPressed: () => _pickPhoto(context),
            icon: Icons.photo_library,
            label: 'Seç',
            color: AppTheme.neonPurple,
            width: 96,
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: GlassmorphicContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.contact_phone, color: AppTheme.neonGreen, size: 24),
                  const SizedBox(width: 10),
                  const Text('İletişim Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedTextField(controller: _phoneController, label: 'Telefon Numarası', icon: Icons.phone, keyboardType: TextInputType.phone, inputFormatters: [NumbersOnlyFormatter()]),
              const SizedBox(height: 16),
              AnimatedTextField(controller: _addressController, label: 'Adres', icon: Icons.home, maxLines: 2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnimatedTextField(
                      controller: _cityController,
                      label: 'İl',
                      icon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedTextField(
                      controller: _districtController,
                      label: 'İlçe',
                      icon: Icons.location_on,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildVasiSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: FractionallySizedBox(
        widthFactor: 0.7,
        alignment: Alignment.center,
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.supervisor_account, color: AppTheme.neonPurple, size: 24),
                  const SizedBox(width: 10),
                  const Text('Vasi Bilgileri (Opsiyonel)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: AnimatedTextField(controller: _vasiNameController, label: 'Vasi Adı Soyadı', icon: Icons.person_4, inputFormatters: [LettersOnlyFormatter()])),
                  const SizedBox(width: 16),
                  Expanded(child: AnimatedTextField(controller: _vasiPhoneController, label: 'Vasi Telefonu', icon: Icons.phone_android, keyboardType: TextInputType.phone, inputFormatters: [NumbersOnlyFormatter()])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleHavaleSelection(bool value) async {
    if (value) {
      final prefs = await SharedPreferences.getInstance();
      final bankName = prefs.getString('bank_name');
      final accountNo = prefs.getString('account_no');
      final ibanNo = prefs.getString('iban_no');
      final recipientName = prefs.getString('recipient_name');

      if (bankName == null || bankName.isEmpty) {
        // Show input dialog
        if (mounted) {
          _showBankDetailsInput(prefs);
        }
      } else {
        // Show existing details
        if (mounted) {
          _showBankDetailsInfo(bankName, accountNo, ibanNo, recipientName);
        }
        setState(() => _paymentHavale = true);
      }
    } else {
      setState(() => _paymentHavale = false);
    }
  }

  void _showBankDetailsInput(SharedPreferences prefs) {
    final bankNameController = TextEditingController();
    final accountNoController = TextEditingController();
    final ibanNoController = TextEditingController();
    final recipientNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Banka Bilgileri', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Lütfen havale/EFT için banka bilgilerinizi giriniz.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              _buildDialogTextField(bankNameController, 'Banka Adı'),
              const SizedBox(height: 10),
              _buildDialogTextField(accountNoController, 'Hesap No', isNumber: true),
              const SizedBox(height: 10),
              _buildDialogTextField(ibanNoController, 'IBAN No'),
              const SizedBox(height: 10),
              _buildDialogTextField(recipientNameController, 'Alıcı Adı Soyadı'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await prefs.setString('bank_name', bankNameController.text);
              await prefs.setString('account_no', accountNoController.text);
              await prefs.setString('iban_no', ibanNoController.text);
              await prefs.setString('recipient_name', recipientNameController.text);
              
              if (mounted) {
                Navigator.pop(context);
                setState(() => _paymentHavale = true);
                _showBankDetailsInfo(
                  bankNameController.text,
                  accountNoController.text,
                  ibanNoController.text,
                  recipientNameController.text
                );
              }
            },
            child: const Text('Kaydet', style: TextStyle(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }

  void _showBankDetailsInfo(String? bankName, String? accountNo, String? ibanNo, String? recipientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Kayıtlı Banka Bilgileri', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Banka:', bankName),
            _buildInfoRow('Hesap No:', accountNo),
            _buildInfoRow('IBAN:', ibanNo),
            _buildInfoRow('Alıcı:', recipientName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
               Navigator.pop(context);
               final prefs = await SharedPreferences.getInstance();
               if (mounted) _showBankDetailsInput(prefs);
            },
            child: const Text('Düzenle', style: TextStyle(color: AppTheme.neonBlue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDialogTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.neonGreen),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(color: AppTheme.goldColor, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '-', style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.goldColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.cardColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}.${picked.month}.${picked.year}";
      });
    }
  }

  Widget _buildFinancialSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: FractionallySizedBox(
        widthFactor: 0.7,
        alignment: Alignment.center,
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, color: AppTheme.goldColor, size: 24),
                  const SizedBox(width: 10),
                  const Text('Mali Bilgiler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedTextField(controller: _agreedAmountController, label: 'Anlaşılan Ücret (₺)', icon: Icons.payments, keyboardType: TextInputType.number, inputFormatters: [CurrencyInputFormatter()]),
              const SizedBox(height: 12),
              AnimatedTextField(controller: _paidAmountController, label: 'Ön Ödeme (₺)', icon: Icons.attach_money, keyboardType: TextInputType.number, inputFormatters: [CurrencyInputFormatter()]),
              const SizedBox(height: 24),
              const Text(
                'Ödeme Türü',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPaymentTypeChip('Nakit', Icons.money, _paymentNakit, (value) {
                    setState(() => _paymentNakit = value);
                  }),
                  _buildPaymentTypeChip('Çek', Icons.description, _paymentCek, (value) {
                    setState(() => _paymentCek = value);
                  }),
                  _buildPaymentTypeChip('Havale/EFT', Icons.account_balance, _paymentHavale, (value) {
                    _handleHavaleSelection(value);
                  }),
                  _buildPaymentTypeChip('Taksit', Icons.calendar_month, _paymentTaksit, (value) {
                    setState(() {
                      _paymentTaksit = value;
                      if (!value) {
                        _taksitMiktariController.clear();
                      }
                    });
                  }),
                ],
              ),
              if (_paymentCek) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Çek Bilgileri',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.goldColor),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(_cekVadeTarihiController),
                        child: AbsorbPointer(
                          child: AnimatedTextField(
                            controller: _cekVadeTarihiController,
                            label: 'Taahhüt Vade Tarihi',
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedTextField(
                        controller: _cekFaizOraniController,
                        label: 'Faiz Oranı (%)',
                        icon: Icons.percent,
                        keyboardType: TextInputType.number,
                        inputFormatters: [NumbersOnlyFormatter()],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _cekHamiline = !_cekHamiline;
                                if (_cekHamiline) {
                                  _cekSahibiController.text = 'HAMİLİNE';
                                } else {
                                  _cekSahibiController.clear();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: _cekHamiline ? AppTheme.goldColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.goldColor),
                              ),
                              child: Text(
                                'Hamiline',
                                style: TextStyle(
                                  color: _cekHamiline ? Colors.black : AppTheme.goldColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedTextField(
                              controller: _cekSahibiController,
                              label: 'Çekin Sahibi (Ad Soyad)',
                              icon: Icons.person,
                              enabled: !_cekHamiline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (_paymentTaksit) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Taksit Sayısı',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.3)),
                            ),
                            child: DropdownButton<int>(
                              value: _taksitSayisi,
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: AppTheme.cardColor,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.goldColor),
                              items: List.generate(5, (index) => index + 1)
                                  .map((i) => DropdownMenuItem(
                                        value: i,
                                        child: Text('$i Taksit'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _taksitSayisi = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedTextField(
                        controller: _taksitMiktariController,
                        label: 'Aylık Taksit Tutarı (₺)',
                        icon: Icons.payments,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                      ),
                    ),
                  ],
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildPaymentTypeChip(String label, IconData icon, bool isSelected, Function(bool) onChanged) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: AppTheme.goldColor.withValues(alpha: 0.3),
      checkmarkColor: Colors.white,
      backgroundColor: AppTheme.cardColor.withValues(alpha: 0.5),
      side: BorderSide(
        color: isSelected ? AppTheme.goldColor : Colors.white.withValues(alpha: 0.2),
        width: isSelected ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

// Kamera Tarayıcı Ekranı - Otomatik Algılama ile
class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key, this.preferredFacing});

  final String? preferredFacing;

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraMacOSController? _cameraController;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isAutoScanning = false;
  List<CameraMacOSDevice> _cameras = [];
  Timer? _autoScanTimer;
  int _scanAttempts = 0;
  String _statusMessage = 'Kimlik kartını çerçeve içine yerleştirin';
  late AnimationController _backgroundController;

  CameraMacOSDevice? _pickCameraDevice() {
    if (_cameras.isEmpty) return null;
    if (widget.preferredFacing == null) return _cameras.first;

    final facing = widget.preferredFacing!.toLowerCase();

    CameraMacOSDevice? match;
    for (final cam in _cameras) {
      final name = cam.localizedName?.toLowerCase() ?? '';
      if (facing == _facingFront && (name.contains('front') || name.contains('face') || name.contains('built-in')))
      {
        match = cam;
        break;
      }
      if (facing == _facingBack && (name.contains('back') || name.contains('rear')))
      {
        match = cam;
        break;
      }
    }

    return match ?? _cameras.first;
  }

  List<CameraMacOSDevice> _sortedCameras(List<CameraMacOSDevice> cams) {
    return List<CameraMacOSDevice>.from(cams)
      ..sort((a, b) {
        final aName = a.localizedName?.toLowerCase() ?? '';
        final bName = b.localizedName?.toLowerCase() ?? '';

        final aScore = _cameraScore(aName);
        final bScore = _cameraScore(bName);

        return bScore.compareTo(aScore);
      });
  }

  int _cameraScore(String name) {
    if (name.contains('front') || name.contains('face') || name.contains('built-in')) return 2;
    if (name.contains('back') || name.contains('rear')) return 1;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await CameraMacOS.instance.listDevices(deviceType: CameraMacOSDeviceType.video);
      
      if (_cameras.isNotEmpty) {
        setState(() => _isInitialized = true);
        _cameras = _sortedCameras(_cameras);
        // Kamera hazır olunca otomatik taramayı başlat
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _startAutoScan();
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kamera bulunamadı')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Kamera başlatma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamera hatası: $e')),
        );
        Navigator.pop(context);
      }
    }
  }
  
  void _startAutoScan() {
    setState(() {
      _isAutoScanning = true;
      _statusMessage = 'Kimlik kartı aranıyor...';
    });
    
    // Her 2 saniyede bir tarama yap
    _autoScanTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_scanAttempts >= 10) {
        // 10 denemeden sonra manuel moda geç
        timer.cancel();
        setState(() {
          _isAutoScanning = false;
          _statusMessage = 'Otomatik algılanamadı. Manuel çekim yapın.';
        });
        return;
      }
      
      _scanAttempts++;
      await _tryCaptureAndScan();
    });
  }
  
  Future<void> _tryCaptureAndScan() async {
    if (_cameraController == null || _isCapturing) return;

    try {
      final picture = await _cameraController!.takePicture();
      
      if (picture != null && picture.bytes != null) {
        final originalImage = img.decodeImage(picture.bytes!);
        
        if (originalImage != null) {
          final flippedImage = img.flipHorizontal(originalImage);
          final flippedBytes = img.encodeJpg(flippedImage, quality: 95);
          
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/auto_scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await tempFile.writeAsBytes(flippedBytes);

          // OCR ile kontrol et
          try {
            final text = await NativeOcrService.recognizeText(tempFile.path);
            
            // Kimlik kartı olup olmadığını kontrol et
            if (_isIdCard(text)) {
              _autoScanTimer?.cancel();
              setState(() {
                _statusMessage = 'Kimlik kartı algılandı!';
              });
              
              await Future.delayed(const Duration(milliseconds: 500));
              
              if (mounted) {
                Navigator.pop(context, tempFile.path);
              }
            } else {
              setState(() {
                _statusMessage = 'Taranıyor... (${_scanAttempts}/10)';
              });
            }
          } catch (e) {
            print('OCR hatası: $e');
          }
        }
      }
    } catch (e) {
      print('Otomatik tarama hatası: $e');
    }
  }
  
  bool _isIdCard(String text) {
    final lowerText = text.toLowerCase();
    // Kimlik kartı olduğunu gösteren anahtar kelimeler
    final hasIdKeywords = lowerText.contains('kimlik') || 
                          lowerText.contains('identity') ||
                          lowerText.contains('türkiye') ||
                          lowerText.contains('republic');
    
    // TC numarası var mı
    final hasTcNo = RegExp(r'\b[1-9]\d{10}\b').hasMatch(text);
    
    // İsim formatı var mı (büyük harfli kelimeler)
    final hasNames = RegExp(r'\b[A-ZĞÜŞİÖÇ]{2,}\b').hasMatch(text);
    
    return (hasIdKeywords || hasTcNo) && hasNames;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || _isCapturing) return;
    
    _autoScanTimer?.cancel();
    setState(() => _isCapturing = true);

    try {
      final picture = await _cameraController!.takePicture();
      
      if (picture != null && picture.bytes != null) {
        var originalImage = img.decodeImage(picture.bytes!);
        
        if (originalImage != null) {
          // Sadece ön kamera ise çevir
          if (widget.preferredFacing == _facingFront) {
            originalImage = img.flipHorizontal(originalImage);
          }

          // Overlay çerçevesine göre kırpma işlemi
          // Ekran boyutunu ve overlay boyutunu al
          final screenSize = MediaQuery.of(context).size;
          final overlayWidth = 350.0;
          final overlayHeight = 220.0;

          // Görüntü ve ekran oranlarını hesapla
          // Not: BoxFit.contain kullanıldığı için görüntü ekrana sığdırılmıştır
          // Basit bir yaklaşımla, görüntünün merkezinden overlay oranında keselim
          // Ancak görüntünün tamamı ekranda görünmeyebilir veya boşluklar olabilir
          // Bu yüzden güvenli bir marjla (overlay'in ekrana oranına yakın) keselim
          
          final widthRatio = overlayWidth / screenSize.width;
          final heightRatio = overlayHeight / screenSize.height;
          
          // Biraz pay bırakalım (kullanıcı tam oturtamamış olabilir)
          final cropFactor = 1.2; 
          
          final cropW = (originalImage.width * widthRatio * cropFactor).toInt().clamp(100, originalImage.width);
          final cropH = (originalImage.height * heightRatio * cropFactor).toInt().clamp(100, originalImage.height);
          
          final cropX = (originalImage.width - cropW) ~/ 2;
          final cropY = (originalImage.height - cropH) ~/ 2;
          
          final croppedImage = img.copyCrop(
            originalImage, 
            x: cropX, 
            y: cropY, 
            width: cropW, 
            height: cropH
          );
          
          final processedBytes = img.encodeJpg(croppedImage, quality: 95);
          
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/id_scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await tempFile.writeAsBytes(processedBytes);

          if (mounted) {
            Navigator.pop(context, tempFile.path);
          }
        } else {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/id_scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await tempFile.writeAsBytes(picture.bytes!);

          if (mounted) {
            Navigator.pop(context, tempFile.path);
          }
        }
      }
    } catch (e) {
      print('Fotoğraf çekme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf çekme hatası: $e')),
        );
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    _backgroundController.dispose();
    _cameraController?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kimlik Kartını Tara', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_isInitialized && _cameras.isNotEmpty)
            Builder(
              builder: (context) {
                final selected = _pickCameraDevice();
                final shouldFlip = (widget.preferredFacing ?? '').toLowerCase() != _facingBack;

                final cameraView = CameraMacOSView(
                  deviceId: selected?.deviceId ?? _cameras.first.deviceId,
                  fit: BoxFit.contain,
                  cameraMode: CameraMacOSMode.photo,
                  onCameraInizialized: (controller) {
                    _cameraController = controller;
                  },
                );

                return shouldFlip
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                        child: cameraView,
                      )
                    : cameraView;
              },
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text('Kamera yükleniyor...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          
          // Overlay çerçeve
          Center(
            child: Container(
              width: 350,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isAutoScanning ? AppTheme.neonOrange : AppTheme.neonGreen, 
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Köşe işaretleri
                  Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
                  Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
                  Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
                  Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),
                  // Otomatik tarama animasyonu
                  if (_isAutoScanning)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: AppTheme.neonOrange.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Alt bilgi - Durum mesajı
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isAutoScanning)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.neonOrange,
                      ),
                    ),
                  ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _isAutoScanning ? AppTheme.neonOrange : Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Otomatik tarama göstergesi (buton yerine)
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, _) {
                final t = _backgroundController.value;
                final pulse = 0.8 + (0.2 * (1 + Math.sin(t * 2 * 3.1415)));
                return Opacity(
                  opacity: 0.9,
                  child: Column(
                    children: [
                      Container(
                        width: 86 * pulse,
                        height: 86 * pulse,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(color: AppTheme.neonGreen, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonGreen.withValues(alpha: 0.45),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.autorenew,
                            color: AppTheme.neonGreen,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isAutoScanning ? 'Otomatik tarama sürüyor' : 'Otomatik tarama hazır',
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: AppTheme.neonGreen, width: 4) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: AppTheme.neonGreen, width: 4) : BorderSide.none,
          left: isLeft ? BorderSide(color: AppTheme.neonGreen, width: 4) : BorderSide.none,
          right: !isLeft ? BorderSide(color: AppTheme.neonGreen, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
