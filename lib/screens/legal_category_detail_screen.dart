import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/neon_button.dart';

class LegalCategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  
  const LegalCategoryDetailScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<LegalCategoryDetailScreen> createState() => _LegalCategoryDetailScreenState();
}

class _LegalCategoryDetailScreenState extends State<LegalCategoryDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  int _selectedTab = 0;
  
  // Kategori bilgileri
  Map<String, dynamic> get categoryData => _getCategoryData(widget.categoryName);
  
  // Dinamik renk - kategoriye göre
  Color get categoryColor {
    final colors = [
      AppTheme.neonBlue,
      AppTheme.neonGreen,
      AppTheme.neonPurple,
      AppTheme.neonOrange,
      AppTheme.goldColor,
      AppTheme.neonPink,
    ];
    return colors[widget.categoryName.hashCode % colors.length];
  }
  
  // Dinamik emoji - kategoriye göre
  String get categoryEmoji {
    final emojis = {
      'Ceza Davaları': '⚖️',
      'Boşanma Davaları': '💔',
      'İş Davaları': '💼',
      'Tazminat Davaları': '💰',
      'Gayrimenkul Davaları': '🏠',
      'İcra İflas Davaları': '📜',
      'Ticaret Hukuku Davaları': '🏢',
      'Tüketici Davaları': '🛒',
    };
    return emojis[widget.categoryName] ?? '⚖️';
  }

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getCategoryData(String category) {
    final data = {
      // ANA DAV A KATEGORİLERİ
      'Ceza Davaları': {
        'description': 'Ceza hukuku kapsamındaki tüm dava türleri',
        'subcategories': [
          {
            'title': 'Kasten Öldürme',
            'icon': Icons.dangerous,
            'items': ['Basit kasten öldürme', 'Nitelikli kasten öldürme', 'Tasarlayarak öldürme'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Şüpheli/Sanık/Mağdur', 'type': 'dropdown', 'icon': Icons.people},
              {'name': 'Suçun İşlendiği Tarih', 'type': 'date', 'icon': Icons.calendar_today},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Mahkeme Adı', 'type': 'text', 'icon': Icons.account_balance},
              {'name': 'Dosya No', 'type': 'text', 'icon': Icons.folder},
              {'name': 'Duruşma Tarihi', 'type': 'date', 'icon': Icons.gavel},
              {'name': 'Tanık Listesi', 'type': 'longtext', 'icon': Icons.people_outline},
              {'name': 'Deliller', 'type': 'file', 'icon': Icons.attach_file},
            ],
          },
          {
            'title': 'Kasten Yaralama',
            'icon': Icons.local_hospital,
            'items': ['Basit yaralama', 'Nitelikli yaralama', 'Silahla yaralama'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Yaralanan/Şüpheli', 'type': 'dropdown', 'icon': Icons.people},
              {'name': 'Olay Tarihi', 'type': 'date', 'icon': Icons.calendar_today},
              {'name': 'Yaralanma Derecesi', 'type': 'dropdown', 'icon': Icons.medical_services},
              {'name': 'Sağlık Raporu', 'type': 'file', 'icon': Icons.file_present},
              {'name': 'Tanık Beyanları', 'type': 'longtext', 'icon': Icons.people_outline},
            ],
          },
          {
            'title': 'Hırsızlık/Dolandırıcılık',
            'icon': Icons.lock_open,
            'items': ['Hırsızlık', 'Nitelikli hırsızlık', 'Dolandırıcılık'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Çalınan Eşya/Zarar', 'type': 'longtext', 'icon': Icons.list},
              {'name': 'Tahmini Değer', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Güvenlik Kamerası', 'type': 'file', 'icon': Icons.videocam},
            ],
          },
          {
            'title': 'Kişilere Karşı Suçlar - Yaşam Hakkı',
            'icon': Icons.person_off,
            'items': ['Kasten Öldürme', 'Nitelikli Kasten Öldürme', 'İnsanlığa Karşı Suçlar', 'Soykırım', 'Taksirle Öldürme', 'Taksirle Birden Fazla Kişinin Ölümü', 'İntihar Yardımı', 'İntihara Yönlendirme', 'Çocuk Düşürtme', 'Kadının Rızası ile Çocuk Düşürtme', 'Kadının Rızası Olmaksızın Çocuk Düşürtme'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Mağdur/Müşteki Adı', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Olay Özeti', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Adli Tıp Raporu', 'type': 'file', 'icon': Icons.medical_services},
            ],
          },
          {
            'title': 'Kişilere Karşı Suçlar - Vücut Dokunulmazlığı',
            'icon': Icons.healing,
            'items': ['Kasten Yaralama', 'Neticesi Sebebiyle Ağırlaşmış Kasten Yaralama', 'Silahla Kasten Yaralama', 'Taksirle Yaralama', 'Kötü Muamele', 'İşkence', 'Eziyet', 'Tehdit', 'Şantaj', 'Cebir', 'Tehlikeli Madde Verme', 'Organ veya Doku Ticareti'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Yaralanma Derecesi', 'type': 'dropdown', 'icon': Icons.medical_services},
              {'name': 'Sağlık Raporu', 'type': 'file', 'icon': Icons.file_present},
              {'name': 'Tanık Beyanları', 'type': 'longtext', 'icon': Icons.people_outline},
            ],
          },
          {
            'title': 'Cinsel Suçlar',
            'icon': Icons.block,
            'items': ['Cinsel Saldırı', 'Nitelikli Cinsel Saldırı', 'Çocuğun Cinsel İstismarı', 'Reşit Olmayanla Cinsel İlişki', 'Cinsel Taciz', 'Cinsel Amaçlı Taciz', 'Fuhuş', 'Çocuk Pornografisi', 'Müstehcenlik', 'Cinsel Davranışlarla İlgili Suçlar'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Adli Tıp Raporu', 'type': 'file', 'icon': Icons.medical_services},
              {'name': 'Psikolojik Rapor', 'type': 'file', 'icon': Icons.psychology},
            ],
          },
          {
            'title': 'Hırsızlık Suçları',
            'icon': Icons.local_police,
            'items': ['Hırsızlık', 'Nitelikli Hırsızlık', 'Yağma', 'Konut Dokunulmazlığının İhlali', 'İş Yerinin Dokunulmazlığının İhlali', 'Mala Zarar Verme', 'Güveni Kötüye Kullanma', 'Bedelsiz Senedi Kullanma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Çalınan Eşya/Zarar', 'type': 'longtext', 'icon': Icons.list},
              {'name': 'Tahmini Değer', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Güvenlik Kamerası', 'type': 'file', 'icon': Icons.videocam},
            ],
          },
          {
            'title': 'Dolandırıcılık Suçları',
            'icon': Icons.money_off,
            'items': ['Dolandırıcılık', 'Nitelikli Dolandırıcılık', 'Bilişim Sistemlerini Kullanarak Dolandırıcılık', 'Kredi Kartı Dolandırıcılığı', 'Sigorta Dolandırıcılığı', 'Fatura Dolandırıcılığı', 'Yardım Toplama Dolandırıcılığı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Zarar Miktarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Olay Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Banka Hesap Bilgileri', 'type': 'text', 'icon': Icons.account_balance},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Hakaret ve İftira',
            'icon': Icons.gavel,
            'items': ['Hakaret', 'Kamu Görevlisine Hakaret', 'Cumhurbaşkanına Hakaret', 'Hakaretle İlgili Özel Hükümler', 'İftira', 'İsnat', 'Yalan Tanıklık', 'Yalan Yere Yemin'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Hakaret/İftira İçeriği', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Tanıklar', 'type': 'longtext', 'icon': Icons.people_outline},
              {'name': 'Ekran Görüntüleri/Ses Kaydı', 'type': 'file', 'icon': Icons.screenshot},
            ],
          },
          {
            'title': 'Uyuşturucu Suçları',
            'icon': Icons.medication,
            'items': ['Uyuşturucu Madde İmal ve Ticareti', 'Uyuşturucu Kullanmak İçin Satın Alma', 'Uyuşturucu Kullanma', 'Kullanmak İçin Uyuşturucu Bulundurma', 'Uyuşturucu Kullanımını Kolaylaştırma', 'Uyuşturucu Kullanmaya Teşvik'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Madde Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Miktar', 'type': 'text', 'icon': Icons.numbers},
              {'name': 'Laboratuvar Raporu', 'type': 'file', 'icon': Icons.science},
            ],
          },
          {
            'title': 'Kumar Suçları',
            'icon': Icons.casino,
            'items': ['Kumar Oynanması İçin Yer ve İmkan Sağlama', 'Oyun Tertiplemek', 'Oyun Oynanması İçin Yer Sağlama', 'Hileli Oyun', 'Spor Müsabakalarında Şike'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Tespit Tutanağı', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Kaçakçılık Suçları',
            'icon': Icons.flight_takeoff,
            'items': ['Gümrük Kaçakçılığı', 'Sigara Kaçakçılığı', 'Akaryakıt Kaçakçılığı', 'Göçmen Kaçakçılığı', 'İnsan Ticareti', 'Organ Ticareti', 'Tarihi Eser Kaçakçılığı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Kaçakçılık Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Yakalama Tutanağı', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Devlete Karşı Suçlar',
            'icon': Icons.account_balance,
            'items': ['Devletin Birliğini ve Ülke Bütünlüğünü Bozmak', 'Anayasayı İhlal', 'Cumhurbaşkanına Suikast', 'Terör Örgütü Kurma', 'Terör Örgütüne Üye Olma', 'Silahlı Örgüt Kurma', 'Örgüt Propagandası', 'Casusluk'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'İddia Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'İddianame', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Adliyeye Karşı Suçlar',
            'icon': Icons.balance,
            'items': ['Yalan Tanıklık', 'Yalan Yere Yemin', 'Suç Üstlenme', 'Suç Delillerini Yok Etme', 'Suçluyu Kayırma', 'Delil Karartma', 'Hakimi Etkilemeye Teşebbüs', 'Görevi Yaptırmamak İçin Direnme'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Dava Dosya No', 'type': 'text', 'icon': Icons.folder},
              {'name': 'İddia Konusu', 'type': 'longtext', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Memuriyete Karşı Suçlar',
            'icon': Icons.work,
            'items': ['Görevi Yaptırmamak İçin Direnme', 'Görevi Kötüye Kullanma', 'İstismar', 'Rüşvet', 'İrtikap', 'Zimmet', 'Resmi Belgede Sahtecilik', 'Görevi İhmal', 'Suçu Bildirmeme'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'İlgili Kurum', 'type': 'text', 'icon': Icons.business},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Bilişim Suçları',
            'icon': Icons.computer,
            'items': ['Bilişim Sistemine Girme', 'Sistemi Engelleme', 'Bozma', 'Verileri Yok Etme', 'Verileri Değiştirme', 'Banka Kartlarının Kötüye Kullanılması', 'Hukuka Aykırı Veri Kaydetme', 'Hukuka Aykırı Dinleme'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Zarar Miktarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Teknik Rapor', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Fikri ve Sınai Haklar',
            'icon': Icons.copyright,
            'items': ['Fikir ve Sanat Eserlerinin İhlali', 'Patent Hakkının İhlali', 'Marka Hakkının İhlali', 'Tasarım Hakkının İhlali', 'Coğrafi İşaret Hakkının İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İhlal Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Eser/Patent/Marka Bilgisi', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Tescil Belgesi', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Spor Hukuku Suçları',
            'icon': Icons.sports_soccer,
            'items': ['Şike', 'Teşvik Primi', 'Lisans Sahteciliği', 'Doping', 'Sporda Şiddet', 'Taraftar Şiddeti'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Spor Dalı', 'type': 'text', 'icon': Icons.sports},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Çevre Suçları',
            'icon': Icons.eco,
            'items': ['Çevreyi Kirletme', 'İmar Kirliliği', 'Gürültü Kirliliği', 'Tehlikeli Atıkların Kontrolsüz Boşaltılması', 'İzinsiz Atık Getirme', 'Hayvanları Koruma Kanununa Aykırılık'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Kirlilik Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Çevre Raporu', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Hayvanlara Karşı Suçlar',
            'icon': Icons.pets,
            'items': ['Hayvanlara Eziyet', 'Hayvan Öldürme', 'Hayvan Yaralama', 'Hayvana Bakım Yükümlülüğünü İhlal', 'Hayvan Kavgası Düzenleme', 'Yasaklı Hayvan Bulundurma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Hayvan Türü', 'type': 'text', 'icon': Icons.pets},
              {'name': 'Olay Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Veteriner Raporu', 'type': 'file', 'icon': Icons.medical_services},
            ],
          },
          {
            'title': 'Orman Suçları',
            'icon': Icons.park,
            'items': ['Kasten Orman Yakma', 'Taksirle Orman Yakma', 'İzinsiz Ağaç Kesme', 'Orman Ürünlerini Çalma', 'Ormanda İzinsiz Yapılaşma', 'Orman Fonunu Zimmetine Geçirme'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Zarar Tespiti', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Kültür Varlıklarına Karşı Suçlar',
            'icon': Icons.museum,
            'items': ['Kültür Varlıklarını Kaçırma', 'Kültür Varlıklarını Tahrip Etme', 'İzinsiz Kazı Yapma', 'Sit Alanında İzinsiz İnşaat', 'Koruma Kurallarına Aykırılık'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Varlık/Eser Adı', 'type': 'text', 'icon': Icons.description},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Ekonomik Suçlar',
            'icon': Icons.trending_down,
            'items': ['Tefecilik', 'Piramit Sistemi Kurma', 'Ekonomik Manipülasyon', 'Hisse Senedi Manipülasyonu', 'İçerden Öğrenenlerin Ticareti', 'Piyasa Dolandırıcılığı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Zarar Miktarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Finansal Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Aile İçi Şiddet',
            'icon': Icons.warning,
            'items': ['Eşe Karşı Kasten Yaralama', 'Çocuğa Karşı Kötü Muamele', 'Aile Bireyine Karşı Cinsel Saldırı', 'Zorla Evlendirme', 'Çocuk Kaçırma', 'Reşit Olmayanı Alıkoyma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Şiddet Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Sağlık Raporu', 'type': 'file', 'icon': Icons.medical_services},
              {'name': '6284 Koruma Kararı', 'type': 'file', 'icon': Icons.shield},
            ],
          },
          {
            'title': 'Enerji ve Madencilik Suçları',
            'icon': Icons.power,
            'items': ['Elektrik Kaçak Kullanımı', 'Doğalgaz Kaçak Kullanımı', 'Su Kaçak Kullanımı', 'Sayaç Kırma', 'Sayaç Manipülasyonu', 'Elektrik Şebekesine Zarar Verme', 'Trafo Hırsızlığı', 'Kablo Hırsızlığı', 'Elektrik Direk Hırsızlığı', 'Ruhsatsız Elektrik Üretimi', 'Ruhsatsız Elektrik Dağıtımı', 'Yenilenebilir Enerji Teşvik İhlali', 'Rüzgar Enerjisi Ruhsat İhlali', 'Güneş Enerjisi Ruhsat İhlali', 'Hidroelektrik Ruhsat İhlali', 'Jeotermal Enerji İhlali', 'Nükleer Enerji Güvenlik İhlali', 'Enerji Verimliliği İhlali', 'Maden Ruhsatı İhlali', 'Kaçak Maden Çıkarma', 'Maden Ocağı Güvenlik İhlali', 'Maden Patlamasına Neden Olma', 'Taş Ocağı İşletme İhlali', 'Kum Ocağı İhlali', 'Mermer Ocağı İhlali', 'Petrol Arama Ruhsatı İhlali', 'Petrol İşletme Ruhsatı İhlali', 'Doğalgaz Arama İhlali', 'Doğalgaz İşletme İhlali', 'Kömür Ocağı İhlali', 'Linyit Ocağı İhlali', 'Demir Madeni İhlali', 'Altın Madeni İhlali', 'Gümüş Madeni İhlali', 'Bakır Madeni İhlali', 'Krom Madeni İhlali', 'Bor Madeni İhlali', 'Tuz Ocağı İhlali', 'Toprak Altı Kaynakları İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İhlal Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'İhlal Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Tespit Tutanağı', 'type': 'file', 'icon': Icons.file_present},
              {'name': 'Fotoğraf/Video', 'type': 'file', 'icon': Icons.camera_alt},
            ],
          },
          {
            'title': 'Denizcilik ve Havacılık Suçları',
            'icon': Icons.flight,
            'items': ['Deniz Yetki Belgesi Olmadan Sefer', 'Gemi Sicil İhlali', 'Gemi Milliyeti İhlali', 'Türk Bayrağı Taşıma İhlali', 'Gemi Adamlığı Belge İhlali', 'Kaptan Yetki İhlali', 'Gemi Jurnal İhlali', 'Seyir Güvenliği İhlali', 'Deniz Kazası Bildirim İhlali', 'Denizde Can Kurtarma İhlali', 'Can Simidi ve Can Yeleği İhlali', 'Can Botu İhlali', 'Yangın Söndürme (Gemi) İhlali', 'Telsiz Haberleşme İhlali', 'Radar Kullanım İhlali', 'AIS (Gemi Tanıma Sistemi) İhlali', 'Balast Suyu İhlali', 'Gemi Yakıt İhlali', 'Zift Atma Yasağı İhlali', 'Deniz Çöpü Atma', 'Gemi Atık Suyu Atma', 'Karantina Limanı İhlali', 'Gümrük Limanı İhlali', 'Kaçak Yolcu Taşıma', 'Kaçak Göçmen Taşıma', 'Denizde İnsan Ticareti', 'Denizde Esrar Kaçakçılığı', 'Denizde Silah Kaçakçılığı', 'Korsanlık', 'Deniz Haydutluğu', 'Gemiye El Koyma', 'Kaptan Kaçırma', 'Mürettebat Rehin Alma', 'Denizde Terör Eylemi', 'Gemi Bombalama', 'Havacılık İşletme İhlali', 'Uçak Kaçırma', 'Uçak Bombalama', 'Havada Terör Eylemi', 'Pilot Lisans İhlali', 'Kabin Memuru Lisans İhlali', 'Uçuş Güvenliği İhlali', 'Hava Trafik Kontrolü İhlali', 'Uçak Bakım İhlali', 'Tehlikeli Madde Taşıma (Uçak) İhlali', 'Havalimanı Güvenlik İhlali', 'Yasak Bölge Uçuşu', 'Drone İzinsiz Uçurma', 'Drone ile Gizlilik İhlali', 'Drone ile İzinsiz Görüntü Çekme', 'Askeri Bölgede Drone Uçurma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Yeri/Bölge', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Gemi/Uçak Bilgileri', 'type': 'longtext', 'icon': Icons.directions_boat},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Finansal Suçlar',
            'icon': Icons.account_balance,
            'items': ['Kara Para Aklama', 'Terörizmin Finansmanı', 'Kitle İmha Silahlarının Finansmanı', 'Mali Suçları Araştırma Kurulu İhlali', 'Şüpheli İşlem Bildirim İhlali', 'Müşterini Tanı İhlali', 'Risk Değerlendirmesi İhlali', 'Uyum Programı İhlali', 'Kayıt ve Belge Saklama İhlali', 'Gerçek Lehdar Tespiti İhlali', 'Yüksek Risk Ülke İhlali', 'Politik Açıdan Etkin Kişi İhlali', 'Havaleci (Havacilik) İhlali', 'Alternatif Havale Sistemi İhlali', 'Elektronik Para İhlali', 'Ödeme Hizmetleri İhlali', 'Fon Transfer İhlali', 'Bütçe Hakkı İhlali', 'Kamu Malı İhlali', 'Devlet İhale Kanunu İhlali', 'Kamu İhalelerine Fesat Karıştırma', 'İhale Yasaklısı Olmak', 'Teminat Vermeme', 'Sözleşme Yenileme İhlali', 'Kesin Hesap İhlali', 'İdari Para Cezası Ödememe', 'Sayıştay Denetimi Engelleme', 'Sayıştay Raporlarını Gizleme', 'Kamu Zararı Oluşturma', 'Devlet Malını Çalma', 'Devlet Malına Zarar Verme', 'Ambar Tespit İhlali', 'Tasfiye İhlali', 'Borçlar Kanunu İhlali', 'Cebri İcra İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'İşlem Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'İşlem Tutarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Banka/Kurum Bilgileri', 'type': 'longtext', 'icon': Icons.business},
              {'name': 'Finansal Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Toplumsal Düzen Suçları',
            'icon': Icons.group,
            'items': ['Toplantı ve Gösteri Yürüyüşü İzni Almadan Düzenleme', 'Toplantı Alanı Sınırlarını Aşma', 'Silah veya Patlayıcı ile Toplantıya Katılma', 'Yüzü Kapatarak Toplantıya Katılma', 'Yasadışı Örgüt Toplantısı', 'Sloganlarla Halkı Tahrik', 'Pankart ve Döviz İhlali', 'Bildiri Dağıtma İhlali', 'Yasadışı Ses Düzeni Kullanma', 'Trafik Akışını Engelleme (Toplantı)', 'Resmi Bina Çevresinde Toplantı', 'Okul Çevresinde Toplantı', 'Hastane Çevresinde Toplantı', 'İbadethanelerde Toplantı', 'Askeri Bölgelerde Toplantı', 'İzinsiz Çadır Kurma (Eylem)', 'İzinsiz Stand Açma (Eylem)', 'Oturma Eylemi İhlali', 'Açlık Grevi İhlali', 'Ölüm Orucu İhlali', 'İnsan Zinciri İhlali', 'İzinsiz Afiş Asma', 'İzinsiz Duvar Yazısı', 'Grafiti Yasağı İhlali', 'İzinsiz Heykeltıraş'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Eylem Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Eylem Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Eylem Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Zabıt Tutanağı', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Din ve İbadet Suçları',
            'icon': Icons.church,
            'items': ['Dini Değerleri Alenen Aşağılama', 'Din Görevlilerinin Görev Yerini İşgal', 'Hutbe Sırasında Müdahale', 'Vaaz Sırasında Müdahale', 'İbadet Sırasında Rahatsız Etme', 'Ezan Sırasında Rahatsız Etme', 'Cami İçinde Uygunsuz Davranış', 'Kilise İçinde Uygunsuz Davranış', 'Sinagog İçinde Uygunsuz Davranış', 'İbadethanelerde Sigara İçme', 'İbadethanelerde Yemek Yeme', 'İbadethanelerde Gürültü', 'İbadethanelere Zarar Verme', 'İbadethaneleri Kundaklama', 'İbadethanelerden Hırsızlık', 'Dini Sembollere Hakaret', 'Kutsal Kitaplara Hakaret', 'Mezarlıklara Zarar Verme', 'Mezar Taşlarını Kırma', 'Mezar Açma', 'Cenaze Hırsızlığı', 'Ölü Dokunulmazlığunu İhlal', 'Mezarlıkta Uygunsuz Davranış', 'Türbe Dokunulmazlığı İhlali', 'Hac ve Umre Dolandırıcılığı', 'Vakıf Mallarına Tecavüz', 'Vakıf Gelirlerini Zimmetine Geçirme', 'Dini Yayın İhlali', 'Din İstismarı', 'Tarikat Faaliyeti İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Tanık Beyanları', 'type': 'longtext', 'icon': Icons.people_outline},
            ],
          },
          {
            'title': 'Eğitim Suçları',
            'icon': Icons.school,
            'items': ['Öğretmenlik İzni Olmadan Ders Verme', 'Diploma Sahteciliği', 'Sahte Sertifika Kullanma', 'Sınav Kopya Çekme', 'Kopya Çektirme', 'Sınav Soruları Çalma', 'Not Yükseltme Rüşveti', 'Öğrenci Belgesi Sahteciliği', 'Transkript Sahteciliği', 'Sahte Akademik Unvan', 'Tez İntihal', 'Makale İntihal', 'Araştırma Verileri Manipülasyonu', 'Akademik Sahtekarlık', 'Ödevi Başkasına Yaptırma', 'Özel Ders İhlali', 'Dershane Ruhsat İhlali', 'Etüt Merkezi İhlali', 'Okul Kayıt İhlali', 'Okulda Silah Bulundurma', 'Okulda Bıçak Bulundurma', 'Okulda Uyuşturucu Bulundurma', 'Öğrenciye Şiddet', 'Öğretmene Şiddet', 'Öğrenci İntiharına Sebep Olma', 'Zorbalık (Okul)', 'Siber Zorbalık (Okul)', 'Öğrenci Tacizi', 'Öğrenci Cinsel İstismarı', 'Okul Servisi İhlali', 'Öğrenci Taşıma İhlali', 'Okul Kantini İhlali', 'Okul Yemekhanesi İhlali', 'Okul Bütçesi İhlali', 'Veli Şiddet', 'Okul Müdürü Yolsuzluğu', 'Öğrenci İşleri İhlali', 'Burs Dolandırıcılığı', 'Öğrenci Kredisi İhlali', 'Yurt İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Okul/Kurum Adı', 'type': 'text', 'icon': Icons.business},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Askerle İlgili Diğer Suçlar',
            'icon': Icons.military_tech,
            'items': ['Askere Gitmeme', 'Celp Kaçağı Olma', 'Yoklama Kaçağı Olma', 'Silah Altına Alınmama', 'Sevk Emrine Uymama', 'Bedelli Askerlik İhlali', 'Terhis Tecili İhlali', 'Muaflik Raporu Sahteciliği', 'Askeri Hastane Rapor İhlali', 'Askeri Bölgeye İzinsiz Giriş', 'Askeri Tesise İzinsiz Giriş', 'Askeri Kamp Alanı İhlali', 'Tatbikat Bölgesi İhlali', 'Atış Poligonu İhlali', 'Mayın Bölgesi İhlali', 'Askeri Malzeme Hırsızlığı', 'Askeri Araç Hırsızlığı', 'Askeri Silah Hırsızlığı', 'Askeri Mühimmat Hırsızlığı', 'Askeri Üniforma Giyme', 'Sahte Asker Kimliği', 'Askeri Rütbe Takınma', 'Asker Kaçakçılığı', 'Askere İzinsiz Yardım', 'Askeri Bölgede Fotoğraf Çekme', 'Askeri Bölgede Video Çekme', 'Askeri Sır İfşası', 'NATO Sırrını İfşa', 'Stratejik Bilgi Sızıntısı', 'Kriptolu Belge İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Askeri Birim', 'type': 'text', 'icon': Icons.business},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Özel Yetkili Mahkeme Suçları',
            'icon': Icons.gavel,
            'items': ['Anayasal Düzeni Ortadan Kaldırma', 'Silahlı Terör Örgütü Kurma', 'Silahlı Terör Örgütüne Üye Olma', 'Terör Örgütü Yöneticiliği', 'Terör Örgütü Adına Suç İşleme', 'Terör Örgütüne Eleman Temin', 'Terör Örgütüne Mali Kaynak Sağlama', 'Terör Örgütü Propagandası', 'Terör Örgütünü Övme', 'Örgüt Evinde Kalmak', 'Dağa Çıkmak', 'PKK Üyeliği', 'FETÖ Üyeliği', 'IŞİD Üyeliği', 'El Kaide Üyeliği', 'DHKP-C Üyeliği', 'TKP-ML Üyeliği', 'Dev-Sol Üyeliği', 'Hizbullah Üyeliği', 'Organize Suç Örgütü Kurma', 'Organize Suç Örgütüne Üye Olma', 'Mafya Tipi Örgüt', 'Çete Kurma', 'Çeteye Üye Olma', 'Suç Örgütüne Yardım', 'Suç İşlemek Amacıyla Örgüt Kurma', 'Suç İşlemek Amacıyla Örgüte Üye Olma', 'Siber Terör', 'Nükleer Terör', 'Biyolojik Terör', 'Kimyasal Terör', 'Bomba İmalatı', 'Bomba Yapımına Teşebbüs', 'Patlayıcı Madde Bulundurma', 'El Bombası Bulundurma', 'Molotof Kokteylli Bulundurma', 'C4 Patlayıcı Bulundurma', 'TNT Bulundurma', 'Dinamit Bulundurma', 'Barut Kaçakçılığı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Suç Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'İlgili Örgüt', 'type': 'text', 'icon': Icons.group},
              {'name': 'İddia Belgesi', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Silah Suçları',
            'icon': Icons.dangerous,
            'items': ['Ruhsatsız Silah Bulundurma', 'Ruhsatsız Tabanca Bulundurma', 'Ruhsatsız Tüfek Bulundurma', 'Otomatik Silah Bulundurma', 'Ağır Silah Bulundurma', 'Kesici Alet Taşıma', 'Saldırı Silahı Bulundurma', 'Pompalı Tüfek Bulundurma', 'Av Tüfeği İhlali', 'Susturucu Bulundurma', 'Dürbünlü Tüfek Bulundurma', 'Uzun Namlı Silah Bulundurma', 'Kısa Namlı Silah Bulundurma', 'Yarı Otomatik Silah Bulundurma', 'Fişek Kaçakçılığı', 'Mermi Kaçakçılığı', 'Şarjör Kaçakçılığı', 'Silah Parçası Kaçakçılığı', 'Silah İmalathanesi İşletme', 'Ruhsatsız Silah İmal Etme', 'Silah Ruhsat İhlali', 'Silah Taşıma İzni İhlali', 'Silah Ticareti İzni İhlali', 'Silahla Tehdit', 'Silahla Yaralama', 'Silahla Öldürme', 'Silah Atma (Havaya)', 'Düğünde Silah Sıkma', 'Toplu Taşımada Silah Taşıma', 'Okulda Silah Bulundurma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Silah Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Yakalama Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Zabıt Tutanağı', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Uyuşturucu ile İlgili Diğer Suçlar',
            'icon': Icons.medication,
            'items': ['Eroin Ticareti', 'Kokain Ticareti', 'Esrar Ticareti', 'Metamfetamin Ticareti', 'Ekstazi Ticareti', 'LSD Ticareti', 'Kenevir Ekimi', 'Hint Keneviri Üretimi', 'Haşhaş Ekimi', 'Afyon Üretimi', 'Uyuşturucu Prekursor Madde Ticareti', 'Uyuşturucu İmal Malzemesi Ticareti', 'Uyuşturucu Laboratuvarı Kurma', 'Sentetik Uyuşturucu İmalatı', 'Uyuşturucuyu Paketleme', 'Uyuşturucuyu Saklama', 'Uyuşturucuyu Nakletme', 'Uyuşturucu Kuryeliği', 'Uyuşturucu Satıcılığı', 'Uyuşturucu Dağıtıcılığı', 'Uyuşturucu Toptancılığı', 'Bonzai Ticareti', 'Jamaika Ticareti', 'Captagon Ticareti', 'Khat (Khat Otu) Ticareti', 'Krokodil (Desomorfin) Ticareti', 'Sentetik Kannabinoid Ticareti', 'Fentanyl Ticareti', 'Tramadol Kaçakçılığı', 'Reçeteli İlaç Bağımlılığı Yayma', 'Uyuşturucu Kullanma Mekanı İşletme', 'Uyuşturucu Kullanımına Yer Sağlama', 'Uyuşturucu Kullandırma', 'Çocuğa Uyuşturucu Kullandırma', 'Hamileye Uyuşturucu Kullandırma', 'Okul Yakınında Uyuşturucu Satma', 'Parkta Uyuşturucu Satma', 'İnternetten Uyuşturucu Satma', 'Dark Web\'de Uyuşturucu Ticareti', 'Kripto Para ile Uyuşturucu Alımı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Madde Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Miktar', 'type': 'text', 'icon': Icons.numbers},
              {'name': 'Laboratuvar Raporu', 'type': 'file', 'icon': Icons.science},
            ],
          },
          {
            'title': 'İletişim ve Medya Suçları',
            'icon': Icons.tv,
            'items': ['İzinsiz Radyo Yayını', 'İzinsiz TV Yayını', 'Korsan Yayın', 'Frekans İhlali', 'Yayın İhlali', 'İzinsiz Uydu Yayını', 'RTÜK İhlali', 'Yayın İzleme Raporları İhlali', 'Reklamda Çocuk İstismarı', 'Tütün Reklamı Yasağı İhlali', 'Alkol Reklamı Yasağı İhlali', 'İlaç Reklamı İhlali', 'Yanıltıcı Reklam', 'Abartılı Reklam', 'Haksız Karşılaştırmalı Reklam', 'Gizli Reklam', 'Subliminal Mesaj', 'Product Placement İhlali', 'Sponsor İhlali', 'Telif Hakkı İhlali (Medya)', 'Yayın Hakkı İhlali', 'Komşu Hak İhlali', 'Umuma Açık İşyerinde Telif İhlali', 'Kamuoyunu Yanıltma', 'Sahte Haber Yayma', 'Manipülatif Haber', 'Kişilik Haklarını İhlal Eden Yayın', 'Özel Hayatı İhlal Eden Yayın', 'Mahkeme Kararlarını Etkileyen Yayın', 'Çocuklara Uygun Olmayan Yayın', 'Şiddet İçerikli Yayın', 'Cinsellik İçerikli Yayın', 'Nefret Söylemi Yayını', 'Irkçı Yayın', 'Ayrımcı Yayın', 'Kadına Karşı Şiddet İçeren Yayın', 'Terörü Öven Yayın', 'Suçu Öven Yayın', 'İntihar Teşvik Eden Yayın', 'Anonim Kalma Hakkı İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İhlal Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Yayın Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Yayın Organı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Kayıt/Belge', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
        ],
      },
      
      'Boşanma Davaları': {
        'description': 'Boşanma, mal paylaşımı, velayet ve nafaka davaları',
        'subcategories': [
          {
            'title': 'Anlaşmalı Boşanma',
            'icon': Icons.handshake,
            'items': ['Anlaşmalı boşanma protokolü', 'Mal paylaşımı', 'Velayet anlaşması'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Eş Adı Soyadı', 'type': 'text', 'icon': Icons.people},
              {'name': 'Evlilik Tarihi', 'type': 'date', 'icon': Icons.favorite},
              {'name': 'Çocuk Sayısı', 'type': 'number', 'icon': Icons.child_care},
              {'name': 'Çocukların Yaşları', 'type': 'text', 'icon': Icons.cake},
              {'name': 'Ortak Mal Varlığı', 'type': 'longtext', 'icon': Icons.home},
              {'name': 'Nafaka Talebi', 'type': 'dropdown', 'icon': Icons.attach_money},
              {'name': 'Velayet Tercihi', 'type': 'dropdown', 'icon': Icons.family_restroom},
              {'name': 'Evlilik Cüzdanı', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Çekişmeli Boşanma',
            'icon': Icons.gavel,
            'items': ['Boşanma nedenleri', 'Kusur tespiti', 'Maddi manevi tazminat'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Eş Adı Soyadı', 'type': 'text', 'icon': Icons.people},
              {'name': 'Boşanma Nedeni', 'type': 'dropdown', 'icon': Icons.report},
              {'name': 'Olay Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Tanık Listesi', 'type': 'longtext', 'icon': Icons.people_outline},
              {'name': 'Deliller (Mesaj, Fotoğraf)', 'type': 'file', 'icon': Icons.attach_file},
              {'name': 'Tazminat Talebi', 'type': 'number', 'icon': Icons.money},
            ],
          },
          {
            'title': 'Velayet Davası',
            'icon': Icons.child_care,
            'items': ['Velayetin tespiti', 'Velayet değişikliği', 'Çocukla kişisel ilişki'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Çocuk Adı', 'type': 'text', 'icon': Icons.child_friendly},
              {'name': 'Çocuk Yaşı', 'type': 'number', 'icon': Icons.cake},
              {'name': 'Velayet Talebi Gerekçesi', 'type': 'longtext', 'icon': Icons.article},
              {'name': 'Yaşam Koşulları', 'type': 'longtext', 'icon': Icons.home_work},
              {'name': 'Okul Bilgileri', 'type': 'text', 'icon': Icons.school},
              {'name': 'Sosyal İnceleme Raporu', 'type': 'file', 'icon': Icons.assignment},
            ],
          },
          {
            'title': 'Nafaka Davası',
            'icon': Icons.attach_money,
            'items': ['İştirak nafakası', 'Yoksulluk nafakası', 'Tedbir nafakası'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Nafaka Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Talep Edilen Miktar', 'type': 'number', 'icon': Icons.money},
              {'name': 'Gelir Durumu', 'type': 'longtext', 'icon': Icons.account_balance_wallet},
              {'name': 'Gider Listesi', 'type': 'longtext', 'icon': Icons.receipt_long},
              {'name': 'Maaş Bordrosu', 'type': 'file', 'icon': Icons.receipt},
            ],
          },
          {
            'title': 'Boşanma Sebepleri',
            'icon': Icons.heart_broken,
            'items': ['Zina Sebebiyle Boşanma', 'Hayata Kast Sebebiyle Boşanma', 'Pek Kötü veya Onur Kırıcı Davranış', 'Suç İşleme ve Haysiyetsiz Hayat Sürme', 'Terk Sebebiyle Boşanma', 'Akıl Hastalığı Sebebiyle Boşanma', 'Evlilik Birliğinin Sarsılması', 'Ortak Hayatı Sürdürememe', 'Müşterek Hayatın Yeniden Kurulamaması', 'Evlilik Birliğinin Temelden Sarsılması', 'Ayrılık Sebebiyle Boşanma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Eş Adı Soyadı', 'type': 'text', 'icon': Icons.people},
              {'name': 'Boşanma Sebebi', 'type': 'dropdown', 'icon': Icons.report},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Deliller', 'type': 'file', 'icon': Icons.attach_file},
            ],
          },
          {
            'title': 'Velayet Davaları',
            'icon': Icons.family_restroom,
            'items': ['Velayetin Değiştirilmesi', 'Ortak Velayet', 'Müşterek Velayet Düzenlemesi', 'Velayet Hakkının Kaldırılması', 'Velayet Hakkının İadesi', 'Geçici Velayet Tedbirinin Alınması', 'Velayetin Üçüncü Kişiye Verilmesi', 'Çocuğun Yüksek Yararının Tespiti', 'Velayet Hakkında İhtiyati Tedbir Kararı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Çocuk Adı', 'type': 'text', 'icon': Icons.child_friendly},
              {'name': 'Çocuk Yaşı', 'type': 'number', 'icon': Icons.cake},
              {'name': 'Velayet Talebi Gerekçesi', 'type': 'longtext', 'icon': Icons.article},
              {'name': 'Yaşam Koşulları', 'type': 'longtext', 'icon': Icons.home_work},
              {'name': 'Sosyal İnceleme Raporu', 'type': 'file', 'icon': Icons.assignment},
            ],
          },
          {
            'title': 'Çocukla Kişisel İlişki',
            'icon': Icons.supervised_user_circle,
            'items': ['Çocukla Kişisel İlişki Kurulması', 'Kişisel İlişkinin Düzenlenmesi', 'Kişisel İlişkinin Değiştirilmesi', 'Kişisel İlişkinin Genişletilmesi', 'Kişisel İlişkinin Kısıtlanması', 'Kişisel İlişkinin Kaldırılması', 'Kişisel İlişkinin İadesi', 'Kişisel İlişkinin Teslim ve Tenfiz', 'Gözetim Altında Kişisel İlişki', 'Kişisel İlişki Merkezinde Görüşme', 'Geceleme ile Kişisel İlişki', 'Hafta Sonu Kişisel İlişki', 'Bayram Tatillerinde Kişisel İlişki', 'Yaz Tatilinde Kişisel İlişki', 'Yurt Dışına Çıkışta Kişisel İlişki', 'Büyükanne-Büyükbabanın Çocukla İlişkisi', 'Kardeşlerin Çocukla İlişkisi'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Çocuk Adı', 'type': 'text', 'icon': Icons.child_friendly},
              {'name': 'Görüşme Talebi', 'type': 'dropdown', 'icon': Icons.event},
              {'name': 'Görüşme Sıklığı', 'type': 'text', 'icon': Icons.schedule},
              {'name': 'Özel Durumlar', 'type': 'longtext', 'icon': Icons.info},
            ],
          },
          {
            'title': 'Nafaka Davaları (Detaylı)',
            'icon': Icons.payments,
            'items': ['Tedbir Nafakası', 'İştirak Nafakası', 'Yoksulluk Nafakası', 'Çocuk Nafakası', 'Nafaka Artırımı', 'Nafaka Azaltımı', 'Nafakanın Kaldırılması', 'Geçmiş Nafaka', 'Evlenme Nafakası', 'Doğum Nafakası', 'Eğitim Nafakası', 'Sağlık Nafakası', 'Fazladan Masraf Nafakası', 'Anne-Baba Nafakası', 'Kardeş Nafakası', 'Nafaka İcra Takibi', 'Nafaka Borcu İcra Takibi', 'Nafaka Alacağının Haczi', 'Nafaka Borcunun Yapılandırılması', 'Nafaka Ödememe Nedeniyle Hapis Cezası'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Nafaka Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Talep Edilen Miktar', 'type': 'number', 'icon': Icons.money},
              {'name': 'Gelir Durumu', 'type': 'longtext', 'icon': Icons.account_balance_wallet},
              {'name': 'Gider Listesi', 'type': 'longtext', 'icon': Icons.receipt_long},
              {'name': 'Maaş Bordrosu', 'type': 'file', 'icon': Icons.receipt},
            ],
          },
          {
            'title': 'Mal Payı Davaları',
            'icon': Icons.home_work,
            'items': ['Mal Rejiminin Tasfiyesi', 'Edinilmiş Mallara Katılma Rejimi', 'Mal Paylaşımı', 'Katılma Alacağı', 'Değer Artış Payı', 'Katkı Payı Alacağı', 'Emek Katkı Payı', 'Para Katkı Payı', 'Ev İşlerinde Katkı Payı', 'Çocuk Bakımında Katkı Payı', 'İşyerinde Çalışma Katkı Payı', 'Kişisel Malların Tespiti', 'Edinilmiş Malların Tespiti', 'Mal Rejiminin Başlangıç Tarihinin Tespiti', 'Mal Rejiminin Bitiş Tarihinin Tespiti', 'Artdeğer Alacağı', 'Kötüniyet Tazminatı (Mal Rejimi)', 'Denkleştirme Alacağı', 'Önceden Yapılan Mal Paylaşım Sözleşmesinin İptali', 'Mal Ayrılığı Rejimi Sözleşmesi İptali', 'Paylaşma Mal Ayrılığı Sözleşmesi İptali', 'Malvarlığının Yönetimi Sözleşmesi İptali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Ortak Mal Varlığı', 'type': 'longtext', 'icon': Icons.home},
              {'name': 'Tapu Kayıtları', 'type': 'file', 'icon': Icons.description},
              {'name': 'Banka Hesap Bilgileri', 'type': 'longtext', 'icon': Icons.account_balance},
              {'name': 'Araç Bilgileri', 'type': 'text', 'icon': Icons.directions_car},
              {'name': 'Diğer Değerli Eşyalar', 'type': 'longtext', 'icon': Icons.inventory},
            ],
          },
          {
            'title': 'Evliliğin Butlanı (İptali)',
            'icon': Icons.block,
            'items': ['Evlenme Ehliyetinin Olmaması', 'Akıl Hastalığı Sebebiyle İptal', 'Akıl Zayıflığı Sebebiyle İptal', 'Evlenme Yasağına Uymama', 'Hısımlık Sebebiyle İptal', 'Evli Olmakla Evliliğin İptali (Bigami)', 'Yaş Küçüklüğü Sebebiyle İptal', 'Evlenme İradesinin Sakatlığı', 'Yanılma Sebebiyle İptal', 'Aldatma Sebebiyle İptal', 'Korkutma Sebebiyle İptal', 'Geçici Sebepler ile İptal', 'Evlenme Şekline Aykırılık Sebebiyle İptal'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İptal Sebebi', 'type': 'dropdown', 'icon': Icons.report},
              {'name': 'Evlilik Tarihi', 'type': 'date', 'icon': Icons.favorite},
              {'name': 'İptal Gerekçesi', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Evlilik Cüzdanı', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Ayrılık Davaları',
            'icon': Icons.compare_arrows,
            'items': ['Ayrılık Davası', 'Ortak Konutta Ayrılık Tedbirinin Alınması', 'Birlikte Yaşama Yükümlülüğünün Kaldırılması', 'Ayrı Yaşama İzni', 'Koruyucu Ayrılık Tedbirinin Alınması', 'Geçici Ayrılık Tedbirinin Alınması'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Ayrılık Sebebi', 'type': 'dropdown', 'icon': Icons.report},
              {'name': 'Ayrılık Tarihi', 'type': 'date', 'icon': Icons.event},
              {'name': 'Gerekçe', 'type': 'longtext', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Evlilik Birliği Tespit Davaları',
            'icon': Icons.balance,
            'items': ['Evlilik Birliğinin Devamı', 'Evlilik Birliğinin Korunması Tedbirleri', 'Birlikte Yaşama Yükümlülüğünün Yerine Getirilmesi', 'Eşin Dönüşü', 'Evlilik Birliğinin Sarsılıp Sarsılmadığının Tespiti'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Talep Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Durum Açıklaması', 'type': 'longtext', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Soybağı Davaları',
            'icon': Icons.fingerprint,
            'items': ['Babalık Davası', 'Soybağının Reddi', 'Soybağının İptali', 'Tanıma Davası', 'Tanımanın İptali', 'Evlilik Birliği İçinde Doğan Çocuğun Soybağı', 'Evlilik Dışı Doğan Çocuğun Soybağı', 'DNA Testi ile Babalık Tespiti', 'Annelik Tespiti', 'Soybağının Düzeltilmesi'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Çocuk Adı', 'type': 'text', 'icon': Icons.child_friendly},
              {'name': 'Doğum Tarihi', 'type': 'date', 'icon': Icons.cake},
              {'name': 'Talep Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Nüfus Kayıtları', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Evlat Edinme Davaları',
            'icon': Icons.people_alt,
            'items': ['Evlat Edinme', 'Evlat Edinmenin İptali', 'Evlat Edinmenin Feshi', 'Üvey Evlat Edinme', 'Ortak Evlat Edinme', 'Evlat Edinme İçin Rıza', 'Evlat Edinme Rızasının İptali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Evlat Edinilecek Çocuk', 'type': 'text', 'icon': Icons.child_friendly},
              {'name': 'Çocuğun Yaşı', 'type': 'number', 'icon': Icons.cake},
              {'name': 'Gerekçe', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Vasi ve Kayyım Davaları',
            'icon': Icons.support_agent,
            'items': ['Vasi Tayini', 'Kayyım Tayini', 'Vasinin Değiştirilmesi', 'Vasinin Azli', 'Vesayet Altına Alma', 'Kısıtlama', 'Kısıtlılığın Kaldırılması', 'Vesayetin Kaldırılması', 'Mal Varlığının Yönetimi (Vesayet)', 'Vesayet Denetimi', 'Vesayet Hesapları'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Kısıtlı/Küçük Adı', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'Talep Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Gerekçe', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Sağlık Raporları', 'type': 'file', 'icon': Icons.medical_services},
            ],
          },
          {
            'title': 'Nişanlanma Davaları',
            'icon': Icons.diamond,
            'items': ['Nişanın Bozulması Tazminatı', 'Nişan Hediyelerinin İadesi', 'Nişan Yüzüğünün İadesi', 'Düğün Masraflarının İadesi', 'Nişanlılık Dönemindeki Zararların Tazmini', 'Maddi Tazminat (Nişan Bozulması)', 'Manevi Tazminat (Nişan Bozulması)'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Eski Nişanlı Adı', 'type': 'text', 'icon': Icons.people},
              {'name': 'Nişanlanma Tarihi', 'type': 'date', 'icon': Icons.favorite},
              {'name': 'Bozulma Tarihi', 'type': 'date', 'icon': Icons.event_busy},
              {'name': 'Talep Edilen Miktar', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Fatura ve Makbuzlar', 'type': 'file', 'icon': Icons.receipt},
            ],
          },
          {
            'title': 'Evlilik Sözleşmeleri',
            'icon': Icons.article,
            'items': ['Evlilik Sözleşmesinin İptali', 'Mal Rejimi Sözleşmesinin İptali', 'Evlilik Öncesi Yapılan Sözleşmenin Geçerliliği', 'Aile Konutu Sözleşmesinin İptali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Sözleşme Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Sözleşme Tarihi', 'type': 'date', 'icon': Icons.event},
              {'name': 'İptal Gerekçesi', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Sözleşme Metni', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Aile Konutu Davaları',
            'icon': Icons.house,
            'items': ['Aile Konutu Şerhinin Konulması', 'Aile Konutu Şerhinin Kaldırılması', 'Aile Konutunun Tahsisi', 'Eşin Rızası Olmadan Aile Konutu Tasarruf İptali', 'Aile Konutundan Tahliye', 'Aile Konutunun Kullanım Hakkının Verilmesi'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Konut Adresi', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Tapu Bilgileri', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Talep Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Tapu Fotokopisi', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Şiddet ve Koruma (6284)',
            'icon': Icons.security,
            'items': ['6284 Sayılı Kanun Koruma Kararı', 'Şiddet Uygulayan Eşe Karşı Koruma', 'Aile İçi Şiddete Karşı Tedbir', 'Şiddet Mağduru Eşin Korunması', 'Uzaklaştırma Tedbirinin Alınması', 'Mağdur ve Çocuklara Geçici Maddi Yardım', 'Elektronik Kelepçe Takılması', 'Müşterek Konuttan Uzaklaştırma', 'Kadına Yönelik Şiddet Tazminatı', 'Çocuğa Yönelik Şiddet Tazminatı', 'Psikolojik Şiddet Tazminatı', 'Ekonomik Şiddet Tazminatı', 'Cinsel Şiddet Tazminatı', 'Stalking (Takip Etme)'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Şiddet Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Olay Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Olay Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Olay Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Sağlık Raporu', 'type': 'file', 'icon': Icons.medical_services},
              {'name': 'Kolluk Tutanağı', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
          {
            'title': 'Boşanma Sonrası Davalar',
            'icon': Icons.restore,
            'items': ['Boşanma Sonrası Soyadı', 'Eski Soyadına Dönme', 'Evlilik Soyadını Kullanmaya Devam', 'Boşanma Kararının Düzeltilmesi', 'Boşanma Kararının İptali', 'Yabancı Ülke Boşanma Kararının Tanınması', 'Yabancı Boşanma Kararının Tenfizi'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Talep Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Boşanma Tarihi', 'type': 'date', 'icon': Icons.event},
              {'name': 'Boşanma Kararı', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Miras ve Boşanma',
            'icon': Icons.account_balance_wallet,
            'items': ['Boşanma Sonrası Miras Hakkının Tespiti', 'Muvazaalı Boşanmanın Tespiti', 'Boşanmada Mal Kaçırmanın Önlenmesi', 'Mal Rejiminde Hile Tespiti'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İddia Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'İlgili Malvarlığı', 'type': 'longtext', 'icon': Icons.home},
              {'name': 'Deliller', 'type': 'file', 'icon': Icons.attach_file},
            ],
          },
          {
            'title': 'Özel Durumlar',
            'icon': Icons.filter_alt,
            'items': ['Konsoloslukta Yapılan Evliliğin İptali', 'Dini Nikah İle Evliliğin Tespiti', 'Imam Nikahının Hukuki Sonuçları', 'Yabancı Uyruklu Eş ile Boşanma', 'Lahey Sözleşmesi Çocuğun İadesi', 'Uluslararası Çocuk Kaçırma', 'Çocuğun Yurt Dışına Çıkarılması Yasağı', 'Çocuğun Pasaport İşlemleri İzni', 'Gaiplik Sebebiyle Boşanma', 'Uzun Süre Hapishanede Kalma Boşanması', 'Hastalık Sebebiyle Boşanma (Bulaşıcı)', 'İkinci Evlilik Yapma İzni', 'Vekaletle Evlenme İptali', 'Yurt Dışında Yapılan Evliliğin Tescili', 'Müslüman Olmayan Eşle Boşanma', 'Türk Vatandaşlığı Kaybı ve Boşanma', 'Trans Birey Boşanma', 'Cinsiyet Değişikliği Sonrası Evlilik', 'Engellilik Durumunda Boşanma', 'Zihinsel Engelli Eşle Boşanma', 'Alkol-Uyuşturucu Bağımlısı Eşle Boşanma', 'Kumar Bağımlısı Eşle Boşanma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Özel Durum Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Durum Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'İlgili Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
        ],
      },
      
      'İş Davaları': {
        'description': 'İşçi-işveren arasındaki uyuşmazlıklar ve iş hukuku davaları',
        'subcategories': [
          {
            'title': 'İşe İade Davası',
            'icon': Icons.restore,
            'items': ['Haksız Fesih', 'Geçerli Sebep Yokluğu', 'Usulsüz Fesih', 'Sendika Üyeliği', 'Hamilelik/Doğum İzni', '4857 S. Kanun'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İşveren Unvanı', 'type': 'text', 'icon': Icons.business},
              {'name': 'İşe Giriş Tarihi', 'type': 'date', 'icon': Icons.work_history},
              {'name': 'Fesih Tarihi', 'type': 'date', 'icon': Icons.event_busy},
              {'name': 'Fesih Gerekçesi', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Son Brüt Ücret', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'İş Sözleşmesi', 'type': 'file', 'icon': Icons.article},
            ],
          },
          {
            'title': 'İşçi Alacakları Davası',
            'icon': Icons.payments,
            'items': ['Kıdem Tazminatı', 'İhbar Tazminatı', 'Fazla Mesai', 'Yıllık İzin', 'Ulusal Bayram Tatil', 'Hafta Tatili', 'Prim'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İşveren', 'type': 'text', 'icon': Icons.business},
              {'name': 'Çalışma Süresi', 'type': 'text', 'icon': Icons.timer},
              {'name': 'Alacak Kalemleri', 'type': 'longtext', 'icon': Icons.list_alt},
              {'name': 'Bordro/Banka Dekontları', 'type': 'file', 'icon': Icons.receipt},
            ],
          },
          {
            'title': 'İş Kazası ve Meslek Hastalığı',
            'icon': Icons.local_hospital,
            'items': ['İş Kazası Tazminatı', 'Meslek Hastalığı', 'İşveren Kusur Sorumluluğu', 'SGK Rücu Davası', 'Sürekli İş Göremezlik'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İşveren', 'type': 'text', 'icon': Icons.business},
              {'name': 'Kaza Tarihi', 'type': 'datetime', 'icon': Icons.calendar_today},
              {'name': 'İş Göremezlik Oranı', 'type': 'text', 'icon': Icons.medical_information},
              {'name': 'Sağlık Kurulu Raporu', 'type': 'file', 'icon': Icons.medical_services},
            ],
          },
          {
            'title': 'Mobbing (Psikolojik Taciz) Davası',
            'icon': Icons.psychology_alt,
            'items': ['Yıldırma', 'Dışlama', 'Aşağılama', 'İtibar Zedeleme', 'Manevi Tazminat', 'Maddi Tazminat'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İşveren/Fail', 'type': 'text', 'icon': Icons.business},
              {'name': 'Mobbing Olayları', 'type': 'longtext', 'icon': Icons.event_note},
              {'name': 'Tanıklar', 'type': 'longtext', 'icon': Icons.people},
              {'name': 'Deliller', 'type': 'file', 'icon': Icons.folder_open},
            ],
          },
          {
            'title': 'Cinsel Taciz Davası',
            'icon': Icons.report_problem,
            'items': ['İşyerinde Cinsel Taciz', 'Ayrımcılık', 'Tazminat Talebi', 'Fesih', 'Şikayet'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Fail Bilgisi', 'type': 'text', 'icon': Icons.person_off},
              {'name': 'Olay Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Deliller', 'type': 'file', 'icon': Icons.attach_file},
            ],
          },
          {
            'title': 'Toplu İş Sözleşmesi ve Grev Davaları',
            'icon': Icons.groups,
            'items': ['Toplu İş Sözleşmesi İptali', 'Grev Yasağı', 'Lokavt', 'Sendika Hakları', 'Toplu İşten Çıkarma'],
            'requiredFields': [
              {'name': 'Sendika/İşçi Temsilcisi', 'type': 'text', 'icon': Icons.groups},
              {'name': 'İşveren', 'type': 'text', 'icon': Icons.business},
              {'name': 'Uyuşmazlık Konusu', 'type': 'longtext', 'icon': Icons.gavel},
              {'name': 'TİS/Grev Kararı', 'type': 'file', 'icon': Icons.description},
            ],
          },
        ],
      },
      
      'Tazminat Davaları': {
        'description': 'Haksız fiil ve sözleşme ihlalinden doğan tazminat talepleri',
        'subcategories': [
          {
            'title': 'Trafik Kazası Tazminatı',
            'icon': Icons.car_crash,
            'items': ['Maddi Tazminat', 'Manevi Tazminat', 'Destekten Yoksun Kalma', 'Araç Hasarı', 'Gelir Kaybı', 'Bakım Giderleri', 'Cenaze Masrafları'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Kaza Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'Kaza Yeri', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Kusur Oranı', 'type': 'text', 'icon': Icons.percent},
              {'name': 'Sağlık Raporu', 'type': 'file', 'icon': Icons.medical_services},
              {'name': 'Kaza Tespit', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'İş Kazası Tazminatı',
            'icon': Icons.construction,
            'items': ['Maluliyet Tazminatı', 'Sürekli İş Göremezlik', 'Ölüm Tazminatı', 'İşveren Kusuru', 'İSG İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İşveren', 'type': 'text', 'icon': Icons.business},
              {'name': 'Kaza Tarihi', 'type': 'datetime', 'icon': Icons.access_time},
              {'name': 'İş Göremezlik Raporu', 'type': 'file', 'icon': Icons.medical_services},
            ],
          },
          {
            'title': 'Sağlık Hukuku Tazminatları',
            'icon': Icons.local_hospital,
            'items': ['Tıbbi Malpraktis', 'Yanlış Teşhis', 'Ameliyat Hatası', 'İlaç Hatası', 'Aydınlatma Eksikliği', 'Hastane Enfeksiyonu', 'Estetik Hata'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Hastane/Doktor', 'type': 'text', 'icon': Icons.local_hospital},
              {'name': 'Müdahale Tarihi', 'type': 'date', 'icon': Icons.calendar_today},
              {'name': 'Tıbbi Raporlar', 'type': 'file', 'icon': Icons.medical_services},
            ],
          },
          {
            'title': 'Kişilik Hakları Tazminatı',
            'icon': Icons.shield,
            'items': ['Özel Hayatın Gizliliği İhlali', 'Şeref ve Haysiyet İhlali', 'Basın Yoluyla Hakaret', 'Sosyal Medyada Hakaret', 'İsim Hakkı İhlali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İhlal Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Deliller', 'type': 'file', 'icon': Icons.attach_file},
            ],
          },
          {
            'title': 'Ürün Sorumluluğu Tazminatı',
            'icon': Icons.inventory_2,
            'items': ['Ayıplı Ürün', 'Tehlikeli Ürün', 'Patlayan Ürün', 'Zehirlenme', 'Üretici Kusuru'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Ürün Bilgisi', 'type': 'text', 'icon': Icons.shopping_bag},
              {'name': 'Üretici/Satıcı', 'type': 'text', 'icon': Icons.store},
            ],
          },
          {
            'title': 'Hayvan Saldırısı Tazminatı',
            'icon': Icons.pets,
            'items': ['Köpek Isırması', 'Hayvan Saldırısı', 'Evcil Hayvan Zararı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Hayvan Sahibi', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'Sağlık Raporu', 'type': 'file', 'icon': Icons.medical_services},
            ],
          },
          {
            'title': 'Manevi Tazminat Davaları',
            'icon': Icons.favorite_border,
            'items': ['Üzüntü ve Elem', 'Acı ve Keder', 'Psikolojik Travma', 'Şok'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Olay Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Psikolojik Rapor', 'type': 'file', 'icon': Icons.psychology},
            ],
          },
          {
            'title': 'Maddi Tazminat Davaları',
            'icon': Icons.attach_money,
            'items': ['Gerçek Zarar', 'Yoksun Kalınan Kar', 'Tedavi Masrafları', 'İş Gücü Kaybı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Zarar Miktarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Belgeler', 'type': 'file', 'icon': Icons.file_present},
            ],
          },
        ],
      },
      
      'Gayrimenkul Davaları': {
        'description': 'Taşınmaz mallar ile ilgili uyuşmazlıklar',
        'subcategories': [
          {
            'title': 'Tapu İptali ve Tescil Davası',
            'icon': Icons.edit_document,
            'items': ['Tapu İptali', 'Tescil Talebi', 'Sahtecilik İddiası', 'Tapudaki Hata Düzeltme', 'Zilyetliğe Dayalı Tescil', 'Kat Mülkiyeti Tesisi'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Taşınmaz Adresi', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Ada/Parsel', 'type': 'text', 'icon': Icons.map},
              {'name': 'İl/İlçe/Mahalle', 'type': 'text', 'icon': Icons.location_city},
              {'name': 'Tapu Kaydı', 'type': 'file', 'icon': Icons.description},
              {'name': 'Satış Sözleşmesi', 'type': 'file', 'icon': Icons.receipt},
            ],
          },
          {
            'title': 'İzale-i Şüyu (Ortaklığın Giderilmesi)',
            'icon': Icons.splitscreen,
            'items': ['Paylı Mülkiyetin Giderilmesi', 'Satış Yoluyla Paylaşım', 'Aynen Taksim', 'İcbari Satış', 'Kat Mülkiyeti Dönüşümü'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Paydaş Listesi', 'type': 'longtext', 'icon': Icons.people},
              {'name': 'Paylar ve Oranlar', 'type': 'text', 'icon': Icons.pie_chart},
              {'name': 'Taşınmaz Bilgileri', 'type': 'text', 'icon': Icons.home},
              {'name': 'Tapu Belgesi', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Kira ve İrtifak Hakkı Davaları',
            'icon': Icons.key,
            'items': ['Kira Bedelinin Tespiti', 'Kira Tespiti İtiraz', 'İrtifak Hakkı Tesisi', 'İntifa Hakkı', 'Oturma Hakkı', 'Geçit Hakkı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Taşınmaz Bilgileri', 'type': 'text', 'icon': Icons.home},
              {'name': 'Mevcut Kira Bedeli', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Kira Sözleşmesi', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Tahliye Davaları',
            'icon': Icons.exit_to_app,
            'items': ['Süre Bitimi', 'Kiracı Temerrüdü', 'Mal Sahibi İhtiyacı', 'Kiraya Verenin Tahliyesi', 'İhtarname', 'İcra Yoluyla Tahliye'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Kiracı Bilgileri', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'Taşınmaz Adresi', 'type': 'text', 'icon': Icons.location_on},
              {'name': 'Kira Sözleşmesi', 'type': 'file', 'icon': Icons.description},
              {'name': 'İhtar/Fesih Bildirimi', 'type': 'file', 'icon': Icons.email},
            ],
          },
          {
            'title': 'Müdahale Meni (Elatmanın Önlenmesi)',
            'icon': Icons.block,
            'items': ['Mülkiyet Hakkına Müdahale', 'Zilyetliğe Müdahale', 'İmar Kaçağına Müdahale', 'İnşaat Durdurma'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Müdahale Eden', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'Müdahale Türü', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Fotoğraflar', 'type': 'file', 'icon': Icons.photo_camera},
            ],
          },
          {
            'title': 'İmar ve Kamulaştırma Davaları',
            'icon': Icons.domain,
            'items': ['İmar Planına İtiraz', 'Kamulaştırma Bedeline İtiraz', 'Kamulaştırmasız El Atma', 'İmar Durumu İtiraz', 'Ruhsat İptali'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Taşınmaz Bilgileri', 'type': 'text', 'icon': Icons.home},
              {'name': 'İdare', 'type': 'text', 'icon': Icons.account_balance},
              {'name': 'İmar Planı/Karar', 'type': 'file', 'icon': Icons.map},
            ],
          },
          {
            'title': 'Kamulaştırma Davaları',
            'icon': Icons.account_balance,
            'items': ['Bedel Tespiti', 'Acele Kamulaştırma', 'Kamulaştırmasız El Atma', 'Kamu Yararı İtirazı', 'Değer Artış Payı'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Taşınmaz Bilgileri', 'type': 'text', 'icon': Icons.home},
              {'name': 'Kamulaştıran İdare', 'type': 'text', 'icon': Icons.business},
              {'name': 'Kamulaştırma Kararı', 'type': 'file', 'icon': Icons.gavel},
              {'name': 'Bilirkişi Raporu', 'type': 'file', 'icon': Icons.assessment},
            ],
          },
        ],
      },
      
      'İcra İflas Davaları': {
        'description': 'Borç tahsili, haciz işlemleri ve iflas süreçleri',
        'subcategories': [
          {
            'title': 'İlamlı İcra Takibi',
            'icon': Icons.gavel,
            'items': ['Mahkeme Kararı İcrası', 'Haciz İşlemleri', 'Taşınır Haczi', 'Taşınmaz Haczi', 'Alacak Haczi', 'İcra İnkar Tazminatı'],
            'requiredFields': [
              {'name': 'Alacaklı Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Borçlu Adı Soyadı', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'Alacak Miktarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Mahkeme İlamı', 'type': 'file', 'icon': Icons.description},
              {'name': 'İcra Dosya No', 'type': 'text', 'icon': Icons.folder},
            ],
          },
          {
            'title': 'İlamsız İcra Takibi',
            'icon': Icons.receipt_long,
            'items': ['Kambiyo Senetleri (Çek/Senet)', 'Adi Alacak Takibi', 'Ödeme Emri', 'İtiraz', 'İtirazın Kaldırılması', 'İpoteğin Paraya Çevrilmesi'],
            'requiredFields': [
              {'name': 'Alacaklı Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Borçlu Adı Soyadı', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'Alacak Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Alacak Tutarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Çek/Senet', 'type': 'file', 'icon': Icons.credit_card},
            ],
          },
          {
            'title': 'İtirazın İptali Davası',
            'icon': Icons.cancel_presentation,
            'items': ['İtirazın Kaldırılması', 'İtirazın Haksızlığı', 'İcranın Devamı', 'Geçici Haciz'],
            'requiredFields': [
              {'name': 'Alacaklı Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'İcra Dosya No', 'type': 'text', 'icon': Icons.folder},
              {'name': 'İtiraz Belgesi', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'İstihkak Davası',
            'icon': Icons.verified_user,
            'items': ['Haczedilen Malın Üçüncü Kişiye Aidiyeti', 'Hacze İtiraz', 'Mülkiyet İddiası'],
            'requiredFields': [
              {'name': 'İstihkak İddia Eden', 'type': 'text', 'icon': Icons.person},
              {'name': 'Haczedilen Mal', 'type': 'text', 'icon': Icons.inventory},
              {'name': 'Mülkiyet Belgesi', 'type': 'file', 'icon': Icons.article},
            ],
          },
          {
            'title': 'Menfi Tespit Davası',
            'icon': Icons.do_not_disturb_on,
            'items': ['Borç Olmadığının Tespiti', 'Rehinli Alacak Yok', 'İcra Takibinin Önlenmesi'],
            'requiredFields': [
              {'name': 'Davacı Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Alacaklı Bilgisi', 'type': 'text', 'icon': Icons.person_outline},
              {'name': 'İddia Edilen Borç', 'type': 'number', 'icon': Icons.money_off},
            ],
          },
          {
            'title': 'İflas Davası',
            'icon': Icons.trending_down,
            'items': ['İflasın Açılması', 'Konkordato', 'İflasın Ertelenmesi', 'Mal Beyanında Bulunma', 'İflas Masası'],
            'requiredFields': [
              {'name': 'Alacaklı/Talep Eden', 'type': 'text', 'icon': Icons.person},
              {'name': 'Borçlu Şirket/Kişi', 'type': 'text', 'icon': Icons.business},
              {'name': 'Alacak Miktarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Mali Tablolar', 'type': 'file', 'icon': Icons.table_chart},
            ],
          },
        ],
      },
      
      'Ticaret Hukuku Davaları': {
        'description': 'Ticari işlemler ve şirketler arası uyuşmazlıklar',
        'subcategories': [
          {
            'title': 'Şirketler Arası Uyuşmazlıklar',
            'icon': Icons.business_center,
            'items': ['Sözleşme İhlali', 'Haksız Rekabet', 'Ticari Alacak', 'Vekalet Ücreti', 'Akreditif İhtilafı', 'Bayilik Anlaşmazlıkları'],
            'requiredFields': [
              {'name': 'Müvekkil Şirket Unvanı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Karşı Taraf Unvanı', 'type': 'text', 'icon': Icons.corporate_fare},
              {'name': 'Uyuşmazlık Konusu', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Sözleşme', 'type': 'file', 'icon': Icons.article},
              {'name': 'Ticari Defterler', 'type': 'file', 'icon': Icons.menu_book},
            ],
          },
          {
            'title': 'Ortaklık ve Şirket Uyuşmazlıkları',
            'icon': Icons.groups,
            'items': ['Ortaktan Çıkarma', 'Kar Payı Dağıtımı', 'Genel Kurul Kararlarının İptali', 'Yönetim Kurulu İptali', 'Anonim/Limited Şirket'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Şirket Unvanı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Ortaklık Payı', 'type': 'text', 'icon': Icons.percent},
              {'name': 'Esas Sözleşme', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Ticari Sözleşmeler',
            'icon': Icons.handshake,
            'items': ['Satım Sözleşmesi', 'Alım-Satım', 'Taşıma Sözleşmesi', 'Simsarlık', 'Komisyon', 'Acentelik', 'Franchise'],
            'requiredFields': [
              {'name': 'Müvekkil Unvanı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Sözleşme Türü', 'type': 'dropdown', 'icon': Icons.category},
              {'name': 'Sözleşme Tutarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Sözleşme Metni', 'type': 'file', 'icon': Icons.article},
            ],
          },
          {
            'title': 'Kambiyo Senetleri Davaları',
            'icon': Icons.receipt,
            'items': ['Çek İptali', 'Çek Hükmünde İptal', 'Senet Tasdiki', 'Bono Tahsili', 'Kambiyo Takibi'],
            'requiredFields': [
              {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Senet/Çek Tutarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Vade Tarihi', 'type': 'date', 'icon': Icons.calendar_today},
              {'name': 'Çek/Senet Fotokopisi', 'type': 'file', 'icon': Icons.credit_card},
            ],
          },
          {
            'title': 'Marka ve Patent Davaları',
            'icon': Icons.copyright,
            'items': ['Marka Tescili', 'Marka İhlali', 'Patent Hakkı', 'Endüstriyel Tasarım', 'Fikri Mülkiyet', 'Haksız Rekabet'],
            'requiredFields': [
              {'name': 'Müvekkil Unvanı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Marka/Patent Adı', 'type': 'text', 'icon': Icons.label},
              {'name': 'Tescil No', 'type': 'text', 'icon': Icons.confirmation_number},
              {'name': 'Tescil Belgesi', 'type': 'file', 'icon': Icons.workspace_premium},
            ],
          },
          {
            'title': 'Haksız Rekabet Davaları',
            'icon': Icons.balance,
            'items': ['Yanıltıcı Reklam', 'Sır İhlali', 'Ticari İtibarı Zedeleme', 'Kopya Ürün', 'Marka Benzetme'],
            'requiredFields': [
              {'name': 'Müvekkil Şirket', 'type': 'text', 'icon': Icons.business},
              {'name': 'Rakip Şirket', 'type': 'text', 'icon': Icons.corporate_fare},
              {'name': 'İhlal Türü', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Deliller', 'type': 'file', 'icon': Icons.folder},
            ],
          },
          {
            'title': 'Konkordato ve İflas',
            'icon': Icons.trending_down,
            'items': ['Konkordato Talebi', 'İflasın Açılması', 'Alacaklılar Toplantısı', 'İflas Masası', 'Yeniden Yapılandırma'],
            'requiredFields': [
              {'name': 'Şirket Unvanı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Borçlar Toplamı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Mali Tablolar', 'type': 'file', 'icon': Icons.table_chart},
              {'name': 'Konkordato Projesi', 'type': 'file', 'icon': Icons.description},
            ],
          },
        ],
      },
      
      'Tüketici Davaları': {
        'description': 'Tüketicinin Korunması Hakkında Kanun kapsamındaki davalar',
        'subcategories': [
          {
            'title': 'Ayıplı Mal Davaları',
            'icon': Icons.broken_image,
            'items': ['Ücretsiz Onarım', 'Malın Değiştirilmesi', 'Ayıp Oranında İndirim', 'Sözleşmeden Dönme', 'Kampanyalı Ürün', 'Garantili Mal'],
            'requiredFields': [
              {'name': 'Tüketici Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Satıcı/Üretici', 'type': 'text', 'icon': Icons.store},
              {'name': 'Ürün Bilgisi', 'type': 'text', 'icon': Icons.inventory_2},
              {'name': 'Ayıbın Türü', 'type': 'longtext', 'icon': Icons.error},
              {'name': 'Fatura/Fiş', 'type': 'file', 'icon': Icons.receipt},
              {'name': 'Garanti Belgesi', 'type': 'file', 'icon': Icons.workspace_premium},
            ],
          },
          {
            'title': 'Ayıplı Hizmet Davaları',
            'icon': Icons.miscellaneous_services,
            'items': ['Hizmetin Yenilenmesi', 'Hizmette İndirim', 'Sözleşmeden Dönme', 'Tazminat', 'Tadilat İşleri', 'Teknik Servis'],
            'requiredFields': [
              {'name': 'Tüketici Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Hizmet Sağlayıcı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Hizmet Türü', 'type': 'text', 'icon': Icons.handyman},
              {'name': 'Ayıp Açıklaması', 'type': 'longtext', 'icon': Icons.description},
              {'name': 'Sözleşme/Fatura', 'type': 'file', 'icon': Icons.receipt},
            ],
          },
          {
            'title': 'Cayma Hakkı Davaları',
            'icon': Icons.undo,
            'items': ['Mesafeli Sözleşme', 'İnternet Alışverişi', '14 Gün İçinde İade', 'Kapıda Satış', 'Paket Tur', 'Devre Tatil'],
            'requiredFields': [
              {'name': 'Tüketici Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Satıcı Firma', 'type': 'text', 'icon': Icons.store},
              {'name': 'Sipariş Tarihi', 'type': 'date', 'icon': Icons.calendar_today},
              {'name': 'Teslim Tarihi', 'type': 'date', 'icon': Icons.local_shipping},
              {'name': 'Cayma Bildirimi', 'type': 'file', 'icon': Icons.email},
              {'name': 'Sipariş Belgesi', 'type': 'file', 'icon': Icons.shopping_bag},
            ],
          },
          {
            'title': 'Tüketici Kredisi Davaları',
            'icon': Icons.credit_card,
            'items': ['Kredi Kartı Taksit', 'Erken Ödeme İndirimi', 'Cayma Hakkı', 'Faiz İptali', 'Haksız EFT', 'Eksik Belge'],
            'requiredFields': [
              {'name': 'Tüketici Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Kredi Veren Kurum', 'type': 'text', 'icon': Icons.account_balance},
              {'name': 'Kredi Tutarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Kredi Sözleşmesi', 'type': 'file', 'icon': Icons.article},
              {'name': 'Ödeme Planı', 'type': 'file', 'icon': Icons.table_chart},
            ],
          },
          {
            'title': 'Konut Finansmanı Davaları',
            'icon': Icons.home,
            'items': ['Mortgage Sözleşmesi', 'Erken Ödeme Faiz İadesi', 'Cayma Hakkı', 'Hatalı Hesap', 'Dosya Masrafı İadesi'],
            'requiredFields': [
              {'name': 'Tüketici Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Banka', 'type': 'text', 'icon': Icons.account_balance},
              {'name': 'Kredi Tutarı', 'type': 'number', 'icon': Icons.attach_money},
              {'name': 'Konut Finansmanı Sözleşmesi', 'type': 'file', 'icon': Icons.description},
            ],
          },
          {
            'title': 'Abonelik ve Üyelik Davaları',
            'icon': Icons.subscriptions,
            'items': ['Otomatik Yenileme', 'İptal Talebi', 'Spor Salonu', 'Streaming Hizmeti', 'Mobil Operatör', 'İnternet Sağlayıcı'],
            'requiredFields': [
              {'name': 'Tüketici Adı Soyadı', 'type': 'text', 'icon': Icons.person},
              {'name': 'Firma Adı', 'type': 'text', 'icon': Icons.business},
              {'name': 'Abonelik Türü', 'type': 'text', 'icon': Icons.card_membership},
              {'name': 'Abonelik Sözleşmesi', 'type': 'file', 'icon': Icons.article},
              {'name': 'İptal/Cayma Bildirimi', 'type': 'file', 'icon': Icons.cancel},
            ],
          },
        ],
      },
    };
    
    return data[category] ?? {
          'description': 'Bu kategori için içerik hazırlanıyor',
          'subcategories': <Map<String, dynamic>>[
            {
              'title': 'Genel ${category} İşlemleri',
              'icon': Icons.description,
              'items': <String>['Danışmanlık', 'Dava Açma', 'Takip'],
              'requiredFields': <Map<String, dynamic>>[
                {'name': 'Müvekkil Adı Soyadı', 'type': 'text', 'icon': Icons.person},
                {'name': 'Açıklama', 'type': 'longtext', 'icon': Icons.description},
                {'name': 'Belgeler', 'type': 'file', 'icon': Icons.attach_file},
              ],
            },
          ],
        };
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
              const Color(0xFF0A0E21),
              const Color(0xFF1A1F3C),
              const Color(0xFF0A0E21),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Row(
                  children: [
                    // Sol taraf - Alt kategoriler
                    _buildCategoryList(),
                    
                    // Sağ taraf - Detay ve form
                    Expanded(
                      flex: 7,
                      child: _buildDetailContent(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: categoryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Logo ve başlık
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoryColor, categoryColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              categoryEmoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categoryData['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Yeni kayıt butonu
          NeonButton(
            onPressed: () => _showAddRecordDialog(),
            icon: Icons.add,
            label: 'Yeni Kayıt',
            color: categoryColor,
            width: 160,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final subcategories = categoryData['subcategories'] as List<Map<String, dynamic>>;
    
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcat = subcategories[index];
          final isSelected = _selectedTab == index;
          
          return FadeInLeft(
            delay: Duration(milliseconds: index * 100),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              categoryColor.withOpacity(0.3),
                              categoryColor.withOpacity(0.1),
                            ],
                          )
                        : null,
                    color: !isSelected
                        ? Colors.white.withOpacity(0.03)
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? categoryColor.withOpacity(0.5)
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          subcat['icon'],
                          color: categoryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          subcat['title'],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent() {
    final subcategories = categoryData['subcategories'] as List<Map<String, dynamic>>;
    if (subcategories.isEmpty) {
      return const Center(
        child: Text(
          'Henüz alt kategori yok',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    
    final selectedSubcat = subcategories[_selectedTab];
    final items = selectedSubcat['items'] as List<String>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeIn(
            child: Text(
              selectedSubcat['title'],
              style: TextStyle(
                color: categoryColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Kapsamdaki maddeler
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: categoryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Kapsanan Suç Türleri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Kaydedilecek bilgiler
          FadeIn(
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: categoryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Dosyaya Kaydedilecek Bilgiler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                _buildFieldsList(selectedSubcat['requiredFields']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsList(List<Map<String, dynamic>> fields) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: fields.map((field) {
        return Container(
          width: (MediaQuery.of(context).size.width - 400) / 2 - 40,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: categoryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  field['icon'],
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFieldTypeLabel(field['type']),
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
      }).toList(),
    );
  }

  String _getFieldTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Metin';
      case 'longtext':
        return 'Uzun Metin';
      case 'number':
        return 'Sayı';
      case 'date':
        return 'Tarih';
      case 'datetime':
        return 'Tarih & Saat';
      case 'dropdown':
        return 'Seçim';
      case 'checkbox':
        return 'Evet/Hayır';
      case 'file':
        return 'Dosya Ekleme';
      default:
        return 'Metin';
    }
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Yeni ${widget.categoryName} Kaydı',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bu özellik yakında eklenecektir.\nTüm form alanları ve veritabanı entegrasyonu hazır hale gelecektir.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: TextStyle(color: categoryColor),
            ),
          ),
        ],
      ),
    );
  }
}
