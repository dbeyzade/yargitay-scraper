import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_model.dart';
import '../models/payment_model.dart';
import '../models/court_date_model.dart';
import '../models/document_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // ==================== MÜVEKKİL İŞLEMLERİ ====================
  
  // Müvekkil ara (TC ile)
  Future<Client?> searchClientByTC(String tcNo) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('tc_no', tcNo)
          .maybeSingle();
      
      if (response != null) {
        return Client.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Müvekkil arama hatası: $e');
      return null;
    }
  }

  // Müvekkili id ile getir
  Future<Client?> getClientById(String id) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return Client.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Müvekkil getirme hatası: $e');
      return null;
    }
  }
  
  // Tüm müvekkilleri getir
  Future<List<Client>> getAllClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .order('created_at', ascending: false);
      
      print('====== VERITABANI SORGUSU ======');
      print('Ham veri: $response');
      print('Veri tipi: ${response.runtimeType}');
      print('Veri sayısı: ${(response as List).length}');
      
      final clients = (response as List)
          .map((e) {
            print('Müvekkil verisi: $e');
            return Client.fromJson(e);
          })
          .toList();
      
      print('Dönüştürülmüş müvekkil sayısı: ${clients.length}');
      for (var client in clients) {
        print('- ${client.firstName} ${client.lastName} (TC: ${client.tcNo}, Tutar: ${client.agreedAmount})');
      }
      print('================================');
      
      return clients;
    } catch (e) {
      print('❌ Müvekkilleri getirme hatası: $e');
      print('Stack trace: $e');
      return [];
    }
  }
  
  // Müvekkil ekle
  Future<Client?> addClient(Client client) async {
    try {
      final response = await _supabase
          .from('clients')
          .insert(client.toJson())
          .select()
          .single();
      
      return Client.fromJson(response);
    } catch (e) {
      // Bubble up so UI can show the real error (constraint, RLS, network, etc.)
      print('Müvekkil ekleme hatası: $e');
      rethrow;
    }
  }
  
  // Müvekkil güncelle
  Future<bool> updateClient(Client client) async {
    try {
      await _supabase
          .from('clients')
          .update(client.toJson())
          .eq('id', client.id);
      return true;
    } catch (e) {
      print('Müvekkil güncelleme hatası: $e');
      return false;
    }
  }
  
  // Müvekkil sil
  Future<bool> deleteClient(String clientId) async {
    try {
      await _supabase
          .from('clients')
          .delete()
          .eq('id', clientId);
      return true;
    } catch (e) {
      print('Müvekkil silme hatası: $e');
      return false;
    }
  }
  
  // ==================== ÖDEME İŞLEMLERİ ====================
  
  // Ödeme ekle ve ana miktarı güncelle
  Future<bool> addPayment(Payment payment) async {
    try {
      // Ödemeyi ekle
      await _supabase.from('payments').insert(payment.toJson());
      
      // Müvekkil bilgisini getir
      final client = await _supabase
          .from('clients')
          .select()
          .eq('id', payment.clientId)
          .single();
      
      // Ana miktarı güncelle
      final currentPaid = (client['paid_amount'] ?? 0).toDouble();
      await _supabase
          .from('clients')
          .update({'paid_amount': currentPaid + payment.amount})
          .eq('id', payment.clientId);
      
      return true;
    } catch (e) {
      print('Ödeme ekleme hatası: $e');
      return false;
    }
  }
  
  // Müvekkilin ödemelerini getir
  Future<List<Payment>> getClientPayments(String clientId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('client_id', clientId)
          .order('payment_date', ascending: false);
      
      return (response as List)
          .map((e) => Payment.fromJson(e))
          .toList();
    } catch (e) {
      print('Ödemeleri getirme hatası: $e');
      return [];
    }
  }
  
  // Ödeme taahhüdü ekle
  Future<bool> addPaymentCommitment(PaymentCommitment commitment) async {
    try {
      await _supabase.from('payment_commitments').insert(commitment.toJson());
      return true;
    } catch (e) {
      print('Ödeme taahhüdü ekleme hatası: $e');
      return false;
    }
  }
  
  // Müvekkilin ödeme taahhütlerini getir
  Future<List<PaymentCommitment>> getClientPaymentCommitments(String clientId) async {
    try {
      final response = await _supabase
          .from('payment_commitments')
          .select()
          .eq('client_id', clientId)
          .order('commitment_date', ascending: true);
      
      return (response as List)
          .map((e) => PaymentCommitment.fromJson(e))
          .toList();
    } catch (e) {
      print('Ödeme taahhütlerini getirme hatası: $e');
      return [];
    }
  }
  
  // Bugünün ödeme taahhütlerini getir
  Future<List<PaymentCommitment>> getTodayPaymentCommitments() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final response = await _supabase
          .from('payment_commitments')
          .select()
          .gte('commitment_date', startOfDay.toIso8601String())
          .lt('commitment_date', endOfDay.toIso8601String())
          .eq('is_completed', false)
          .eq('has_alarm', true);
      
      return (response as List)
          .map((e) => PaymentCommitment.fromJson(e))
          .toList();
    } catch (e) {
      print('Bugünün taahhütlerini getirme hatası: $e');
      return [];
    }
  }
  
  // ==================== MAHKEME TARİHLERİ ====================
  
  // Mahkeme tarihi ekle
  Future<bool> addCourtDate(CourtDate courtDate) async {
    try {
      await _supabase.from('court_dates').insert(courtDate.toJson());
      return true;
    } catch (e) {
      print('Mahkeme tarihi ekleme hatası: $e');
      return false;
    }
  }
  
  // Müvekkilin mahkeme tarihlerini getir
  Future<List<CourtDate>> getClientCourtDates(String clientId) async {
    try {
      final response = await _supabase
          .from('court_dates')
          .select()
          .eq('client_id', clientId)
          .order('court_date', ascending: true);
      
      return (response as List)
          .map((e) => CourtDate.fromJson(e))
          .toList();
    } catch (e) {
      print('Mahkeme tarihlerini getirme hatası: $e');
      return [];
    }
  }
  
  // Yaklaşan mahkeme tarihlerini getir (bugün ve yarın)
  Future<List<CourtDate>> getUpcomingCourtDates() async {
    try {
      final today = DateTime.now();
      final dayAfterTomorrow = today.add(const Duration(days: 2));
      
      final response = await _supabase
          .from('court_dates')
          .select()
          .gte('court_date', DateTime(today.year, today.month, today.day).toIso8601String())
          .lt('court_date', dayAfterTomorrow.toIso8601String())
          .eq('is_completed', false);
      
      return (response as List)
          .map((e) => CourtDate.fromJson(e))
          .toList();
    } catch (e) {
      print('Yaklaşan mahkeme tarihlerini getirme hatası: $e');
      return [];
    }
  }
  
  // ==================== BELGE İŞLEMLERİ ====================
  
  // Belge ekle
  Future<bool> addDocument(ClientDocument document) async {
    try {
      await _supabase.from('client_documents').insert(document.toJson());
      return true;
    } catch (e) {
      print('Belge ekleme hatası: $e');
      return false;
    }
  }
  
  // Müvekkilin belgelerini getir
  Future<List<ClientDocument>> getClientDocuments(String clientId, {String? documentType}) async {
    try {
      var query = _supabase
          .from('client_documents')
          .select()
          .eq('client_id', clientId);
      
      if (documentType != null) {
        query = query.eq('document_type', documentType);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((e) => ClientDocument.fromJson(e))
          .toList();
    } catch (e) {
      print('Belgeleri getirme hatası: $e');
      return [];
    }
  }
  
  // ==================== KATEGORİ İŞLEMLERİ ====================
  
  // Kategori ekle
  Future<bool> addCategory(DocumentCategory category) async {
    try {
      await _supabase.from('document_categories').insert(category.toJson());
      return true;
    } catch (e) {
      print('Kategori ekleme hatası: $e');
      return false;
    }
  }
  
  // Kategorileri getir
  Future<List<DocumentCategory>> getCategories({String? parentId}) async {
    try {
      var query = _supabase.from('document_categories').select();
      
      if (parentId == null) {
        query = query.isFilter('parent_id', null);
      } else {
        query = query.eq('parent_id', parentId);
      }
      
      final response = await query.order('name', ascending: true);
      
      return (response as List)
          .map((e) => DocumentCategory.fromJson(e))
          .toList();
    } catch (e) {
      print('Kategorileri getirme hatası: $e');
      return [];
    }
  }
  
  // ==================== MASRAF İŞLEMLERİ ====================
  
  // Yargılama gideri ekle
  Future<bool> addCourtExpense(String clientId, double amount, String description) async {
    try {
      await _supabase.from('payments').insert({
        'client_id': clientId,
        'amount': amount,
        'description': description,
        'payment_type': 'court_fee',
        'is_income': false,
        'payment_date': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Yargılama gideri ekleme hatası: $e');
      return false;
    }
  }
  
  // Dosya masrafı ekle
  Future<bool> addFileExpense(String clientId, double amount, String description) async {
    try {
      await _supabase.from('payments').insert({
        'client_id': clientId,
        'amount': amount,
        'description': description,
        'payment_type': 'file_expense',
        'is_income': false,
        'payment_date': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Dosya masrafı ekleme hatası: $e');
      return false;
    }
  }
  
  // Müvekkilin tüm masraflarını getir
  Future<List<Payment>> getClientExpenses(String clientId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('client_id', clientId)
          .eq('is_income', false)
          .order('payment_date', ascending: false);
      
      return (response as List)
          .map((e) => Payment.fromJson(e))
          .toList();
    } catch (e) {
      print('Masrafları getirme hatası: $e');
      return [];
    }
  }
  
  // Talep ekle
  Future<bool> addClientRequest(String clientId, String request) async {
    try {
      await _supabase.from('client_requests').insert({
        'client_id': clientId,
        'request': request,
        'created_at': DateTime.now().toIso8601String(),
        'is_completed': false,
      });
      return true;
    } catch (e) {
      print('Talep ekleme hatası: $e');
      return false;
    }
  }
  
  // Müvekkilin taleplerini getir
  Future<List<Map<String, dynamic>>> getClientRequests(String clientId) async {
    try {
      final response = await _supabase
          .from('client_requests')
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Talepleri getirme hatası: $e');
      return [];
    }
  }
}
