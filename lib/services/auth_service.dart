import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client_model.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // SMS Doğrulama kodu gönder
  Future<bool> sendSMSCode(String phoneNumber) async {
    try {
      // 6 haneli kod oluştur
      final code = _generateVerificationCode();
      
      // Kodu veritabanına kaydet
      await _supabase.from('verification_codes').insert({
        'phone_number': phoneNumber,
        'code': code,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        'is_used': false,
      });
      
      // SMS gönderimi için Supabase Edge Function kullanılabilir
      // Burada SMS API entegrasyonu yapılmalı (Twilio, Netgsm, vb.)
      print('SMS Kodu: $code'); // Debug için
      
      return true;
    } catch (e) {
      print('SMS gönderme hatası: $e');
      return false;
    }
  }
  
  // SMS Kodunu doğrula
  Future<bool> verifySMSCode(String phoneNumber, String code) async {
    try {
      final response = await _supabase
          .from('verification_codes')
          .select()
          .eq('phone_number', phoneNumber)
          .eq('code', code)
          .eq('is_used', false)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        // Kodu kullanıldı olarak işaretle
        await _supabase
            .from('verification_codes')
            .update({'is_used': true})
            .eq('id', response['id']);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Kod doğrulama hatası: $e');
      return false;
    }
  }
  
  // İkinci taraf girişi için doğrulama
  Future<SecondPartyUser?> verifySecondPartyUser(String phoneNumber, String code) async {
    try {
      // Önce kodu doğrula
      final isValid = await verifySMSCode(phoneNumber, code);
      if (!isValid) return null;
      
      // İkinci taraf kullanıcısını getir
      final response = await _supabase
          .from('second_party_users')
          .select()
          .eq('phone_number', phoneNumber)
          .eq('is_active', true)
          .maybeSingle();
      
      if (response != null) {
        return SecondPartyUser.fromJson(response);
      }
      return null;
    } catch (e) {
      print('İkinci taraf doğrulama hatası: $e');
      return null;
    }
  }
  
  // Giriş kaydı oluştur
  Future<void> createLoginRecord(String odaId, String loginType) async {
    try {
      await _supabase.from('login_records').insert({
        'user_id': odaId,
        'login_time': DateTime.now().toIso8601String(),
        'login_type': loginType,
      });
      
      // Son giriş bilgisini SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_login', DateTime.now().toIso8601String());
      await prefs.setString('last_login_type', loginType);
    } catch (e) {
      print('Giriş kaydı hatası: $e');
    }
  }
  
  // Çıkış kaydı güncelle
  Future<void> updateLogoutRecord(String odaId) async {
    try {
      final response = await _supabase
          .from('login_records')
          .select()
          .eq('user_id', odaId)
          .isFilter('logout_time', null)
          .order('login_time', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        await _supabase
            .from('login_records')
            .update({'logout_time': DateTime.now().toIso8601String()})
            .eq('id', response['id']);
      }
      
      // Son çıkış bilgisini SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_logout', DateTime.now().toIso8601String());
    } catch (e) {
      print('Çıkış kaydı hatası: $e');
    }
  }
  
  // Son giriş/çıkış bilgilerini getir
  Future<Map<String, String?>> getLastLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'last_login': prefs.getString('last_login'),
      'last_logout': prefs.getString('last_logout'),
      'last_login_type': prefs.getString('last_login_type'),
    };
  }
  
  // İkinci taraf kullanıcısı ekle
  Future<bool> addSecondPartyUser(String lawyerId, String fullName, String phoneNumber) async {
    try {
      await _supabase.from('second_party_users').insert({
        'lawyer_id': lawyerId,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('İkinci taraf kullanıcı ekleme hatası: $e');
      return false;
    }
  }
  
  // İkinci taraf kullanıcılarını listele
  Future<List<SecondPartyUser>> getSecondPartyUsers(String lawyerId) async {
    try {
      final response = await _supabase
          .from('second_party_users')
          .select()
          .eq('lawyer_id', lawyerId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((e) => SecondPartyUser.fromJson(e))
          .toList();
    } catch (e) {
      print('İkinci taraf kullanıcıları listeleme hatası: $e');
      return [];
    }
  }
  
  // İkinci taraf kullanıcısını deaktif et
  Future<bool> deactivateSecondPartyUser(String userId) async {
    try {
      await _supabase
          .from('second_party_users')
          .update({'is_active': false})
          .eq('id', userId);
      return true;
    } catch (e) {
      print('İkinci taraf kullanıcı deaktif etme hatası: $e');
      return false;
    }
  }
  
  // Hesap oluşturuldu bayrağını kontrol et
  Future<bool> isAccountCreated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('account_created') ?? false;
    } catch (e) {
      print('Hesap durumu kontrol hatası: $e');
      return false;
    }
  }
  
  // Hesap oluşturuldu bayrağını ayarla
  Future<void> setAccountCreated(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('account_created', value);
    } catch (e) {
      print('Hesap bayrağı ayarlama hatası: $e');
    }
  }
  
  // Biyometrik giriş için hesap kontrolü
  Future<bool> canUseBiometric() async {
    return await isAccountCreated();
  }
  
  // E-posta ve şifre ile giriş
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      print('🔐 Giriş deneniyor: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        print('✅ Başarıyla giriş yapıldı: ${response.user!.email}');
        // Hesap oluşturuldu bayrağını true yap
        await setAccountCreated(true);
        return {'success': true, 'user': response.user};
      } else {
        print('❌ Giriş başarısız: Kullanıcı bulunamadı');
        return {'success': false, 'error': 'Kullanıcı bulunamadı'};
      }
    } on AuthException catch (e) {
      print('❌ Auth hatası: ${e.message}');
      return {'success': false, 'error': e.message};
    } catch (e) {
      print('❌ Giriş hatası: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // E-posta ve şifre ile kayıt
  Future<Map<String, dynamic>> signUpWithEmail(String email, String password, {
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    try {
      print('📧 E-posta kayıt başlıyor: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'address': address,
        },
      );
      
      print('✅ Supabase Auth Response: ${response.user?.id}');
      
      if (response.user != null) {
        print('✅ Kullanıcı başarıyla kaydedildi: ${response.user!.email}');
        return {'success': true, 'user': response.user};
      }
      
      print('❌ Kayıt başarısız - user null');
      return {'success': false, 'error': 'Kayıt başarısız'};
    } catch (e) {
      print('❌ E-posta kayıt hatası: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
