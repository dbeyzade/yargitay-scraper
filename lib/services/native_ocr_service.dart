import 'package:flutter/services.dart';

class NativeOcrService {
  static const MethodChannel _channel = MethodChannel('com.avukat_portal/ocr');

  /// macOS Vision framework kullanarak görüntüden metin tanıma yapar
  static Future<String> recognizeText(String imagePath) async {
    try {
      final String result = await _channel.invokeMethod('recognizeText', {
        'imagePath': imagePath,
      });
      return result;
    } on PlatformException catch (e) {
      throw Exception('OCR Hatası: ${e.message}');
    }
  }
}
