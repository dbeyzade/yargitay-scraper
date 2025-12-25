import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'legal_category_detail_screen.dart';

class LogoMenuScreen extends StatefulWidget {
  const LogoMenuScreen({super.key});

  @override
  State<LogoMenuScreen> createState() => _LogoMenuScreenState();
}

class _LogoMenuScreenState extends State<LogoMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _searchGlowController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  String _searchQuery = '';

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Ceza Davaları', 'icon': Icons.gavel},
    {'title': 'Boşanma Davaları', 'icon': Icons.heart_broken},
    {'title': 'İş Davaları', 'icon': Icons.work_outline},
    {'title': 'Tazminat Davaları', 'icon': Icons.account_balance_wallet},
    {'title': 'Miras Davaları', 'icon': Icons.family_restroom},
    {'title': 'Gayrimenkul Davaları', 'icon': Icons.home_work},
    {'title': 'İcra İflas Davaları', 'icon': Icons.gavel_rounded},
    {'title': 'Ticaret Hukuku Davaları', 'icon': Icons.business_center},
    {'title': 'Tüketici Davaları', 'icon': Icons.shopping_cart},
    {'title': 'İdari Davaları', 'icon': Icons.admin_panel_settings},
    {'title': 'Velayet ve Nafaka Davaları', 'icon': Icons.child_care},
    {'title': 'Sigorta Davaları', 'icon': Icons.security},
    {'title': 'Fikri Mülkiyet Davaları', 'icon': Icons.lightbulb_outline},
    {'title': 'Sözleşme Davaları', 'icon': Icons.description},
    {'title': 'Aile Hukuku Davaları', 'icon': Icons.family_restroom},
    {'title': 'Şirketler Hukuku Davaları', 'icon': Icons.corporate_fare},
    {'title': 'Kira Davaları', 'icon': Icons.vpn_key},
    {'title': 'Kamulaştırma Davaları', 'icon': Icons.domain},
    {'title': 'Bankerlik Davaları', 'icon': Icons.account_balance},
    {'title': 'Menfi Tespit Davaları', 'icon': Icons.search_off},
    {'title': 'İstirdat Davaları', 'icon': Icons.replay},
    {'title': 'İsim Hakkı Davaları', 'icon': Icons.badge},
    {'title': 'Komşuluk Hukuku Davaları', 'icon': Icons.house},
    {'title': 'Eşya Hukuku Davaları', 'icon': Icons.inventory_2},
    {'title': 'Borçlar Hukuku Davaları', 'icon': Icons.receipt_long},
    {'title': 'Rekabet Hukuku Davaları', 'icon': Icons.trending_up},
    {'title': 'Kişilik Hakları Davaları', 'icon': Icons.person_outline},
    {'title': 'Hakaret Davaları', 'icon': Icons.speaker_notes_off},
    {'title': 'İfade Özgürlüğü Davaları', 'icon': Icons.record_voice_over},
    {'title': 'Ticari Sır ve Rekabet Yasağı Davaları', 'icon': Icons.lock_outline},
    {'title': 'Franchise Davaları', 'icon': Icons.store},
    {'title': 'Havayolu Davaları', 'icon': Icons.flight},
    {'title': 'Deniz Hukuku Davaları', 'icon': Icons.directions_boat},
    {'title': 'İnşaat Hukuku Davaları', 'icon': Icons.construction},
    {'title': 'Yapı Denetim Davaları', 'icon': Icons.engineering},
    {'title': 'Müdahalenin Men\'i Davaları', 'icon': Icons.block},
    {'title': 'Ortaklığın Giderilmesi Davaları', 'icon': Icons.group_remove},
    {'title': 'İpotek Davaları', 'icon': Icons.real_estate_agent},
    {'title': 'Rehin Davaları', 'icon': Icons.local_atm},
    {'title': 'İhtiyati Tedbir ve Haciz Davaları', 'icon': Icons.warning_amber},
    {'title': 'Sulh Hukuk Davaları', 'icon': Icons.handshake},
    {'title': 'Asliye Hukuk Davaları', 'icon': Icons.balance},
    {'title': 'Asliye Ticaret Davaları', 'icon': Icons.business_center},
    {'title': 'Tüketici Mahkemeleri Davaları', 'icon': Icons.shopping_bag},
    {'title': 'Kadastro Davaları', 'icon': Icons.map},
    {'title': 'Çevre Hukuku Davaları', 'icon': Icons.eco},
    {'title': 'Enerji Hukuku Davaları', 'icon': Icons.bolt},
    {'title': 'Gayrimaddi Haklara Tecavüz Davaları', 'icon': Icons.copyright},
    {'title': 'Alan Adı Uyuşmazlıkları', 'icon': Icons.language},
    {'title': 'E-ticaret Davaları', 'icon': Icons.shopping_basket},
    {'title': 'Medya ve İletişim Hukuku Davaları', 'icon': Icons.connected_tv},
    {'title': 'Sanat Eserleri Davaları', 'icon': Icons.palette},
    {'title': 'Spor Hukuku Davaları', 'icon': Icons.sports_soccer},
    {'title': 'Sağlık Hukuku Davaları', 'icon': Icons.local_hospital},
    {'title': 'Veteriner Hukuku Davaları', 'icon': Icons.pets},
    {'title': 'Tarım Hukuku Davaları', 'icon': Icons.agriculture},
    {'title': 'Su Hukuku Davaları', 'icon': Icons.water_drop},
    {'title': 'Maden Hukuku Davaları', 'icon': Icons.landscape},
    {'title': 'İmar Hukuku Davaları', 'icon': Icons.location_city},
    {'title': 'Sosyal Güvenlik Davaları', 'icon': Icons.health_and_safety},
    {'title': 'Vergi Davaları', 'icon': Icons.receipt_long},
    {'title': 'Gümrük Davaları', 'icon': Icons.local_shipping},
    {'title': 'Disiplin Davaları', 'icon': Icons.rule},
    {'title': 'Nüfus Davaları', 'icon': Icons.people_outline},
    {'title': 'Pasaport ve Seyahat Belgesi Davaları', 'icon': Icons.flight_takeoff},
    {'title': 'Göç ve İltica Davaları', 'icon': Icons.connecting_airports},
    {'title': 'Vatandaşlık Davaları', 'icon': Icons.flag},
    {'title': 'Seçim Hukuku Davaları', 'icon': Icons.how_to_vote},
    {'title': 'Siyasi Parti ve Dernek Davaları', 'icon': Icons.groups},
    {'title': 'Vakıf Davaları', 'icon': Icons.volunteer_activism},
    {'title': 'Sendika Davaları', 'icon': Icons.diversity_3},
    {'title': 'Kooperatif Davaları', 'icon': Icons.group_work},
    {'title': 'Arabuluculuk Sonrası Davaları', 'icon': Icons.mediation},
    {'title': 'Tahkim Davaları', 'icon': Icons.balance},
    {'title': 'Uluslararası Hukuk Davaları', 'icon': Icons.public},
    {'title': 'Yabancılar ve Uluslararası Koruma Davaları', 'icon': Icons.verified_user},
    {'title': 'Milletlerarası Özel Hukuk Davaları', 'icon': Icons.travel_explore},
    {'title': 'Kara Taşıma Davaları', 'icon': Icons.local_shipping},
    {'title': 'CMR Davaları', 'icon': Icons.fire_truck},
    {'title': 'Kargo ve Lojistik Davaları', 'icon': Icons.local_shipping},
    {'title': 'Havale-EFT Davaları', 'icon': Icons.sync_alt},
    {'title': 'Kredi Kartı Davaları', 'icon': Icons.credit_card},
    {'title': 'Mobil Ödeme Davaları', 'icon': Icons.phone_android},
    {'title': 'Kripto Para Davaları', 'icon': Icons.currency_bitcoin},
    {'title': 'Blockchain ve NFT Davaları', 'icon': Icons.grid_view},
    {'title': 'Yapay Zeka ve Teknoloji Davaları', 'icon': Icons.psychology},
    {'title': 'Otonom Araçlar Davaları', 'icon': Icons.drive_eta},
    {'title': 'Drone Davaları', 'icon': Icons.flight},
    {'title': 'Siber Güvenlik Davaları', 'icon': Icons.shield},
    {'title': 'Sosyal Medya Davaları', 'icon': Icons.thumb_up},
    {'title': 'Influencer ve Reklam Davaları', 'icon': Icons.camera_alt},
    {'title': 'Oyun ve E-spor Davaları', 'icon': Icons.sports_esports},
    {'title': 'Streaming Platform Davaları', 'icon': Icons.live_tv},
    {'title': 'Yazılım Lisans Davaları', 'icon': Icons.code},
    {'title': 'Veri Koruma Davaları', 'icon': Icons.privacy_tip},
    {'title': 'Telekomünikasyon Davaları', 'icon': Icons.cell_tower},
    {'title': 'Uydu Yayın Davaları', 'icon': Icons.satellite_alt},
    {'title': 'Enerji Abonelik Davaları', 'icon': Icons.electrical_services},
    {'title': 'Atık Yönetimi Davaları', 'icon': Icons.recycling},
    {'title': 'Hayvan Hakları Davaları', 'icon': Icons.cruelty_free},
    {'title': 'Noter İşlemleri Davaları', 'icon': Icons.verified},
    {'title': 'Vasi ve Kayyım Davaları', 'icon': Icons.supervised_user_circle},
    {'title': 'Gaiplik Davaları', 'icon': Icons.person_search},
    {'title': 'Evlilik Dışı İlişki Davaları', 'icon': Icons.favorite_border},
    {'title': 'Çocuk Teslimine İlişkin Davaları', 'icon': Icons.escalator_warning},
    {'title': 'Tedbir Nafakası Davaları', 'icon': Icons.monetization_on},
    {'title': 'Yoksulluk Nafakası Davaları', 'icon': Icons.money_off},
    {'title': 'İştirak Nafakası Davaları', 'icon': Icons.paid},
    {'title': 'Mal Rejimi Davaları', 'icon': Icons.inventory},
    {'title': 'Maddi Tazminat Davaları', 'icon': Icons.price_check},
    {'title': 'Destekten Yoksun Kalma Davaları', 'icon': Icons.support},
    {'title': 'Sağlık Kurulu Davaları', 'icon': Icons.medical_services},
    {'title': 'Engellilik Davaları', 'icon': Icons.accessible},
    {'title': 'Nafaka Takibi Davaları', 'icon': Icons.track_changes},
    {'title': 'Veraset İlamı İtiraz Davaları', 'icon': Icons.assignment_late},
    {'title': 'Tenkis Davaları', 'icon': Icons.remove_circle_outline},
    {'title': 'Muris Muvazaası Davaları', 'icon': Icons.visibility_off},
    {'title': 'Mirasta İstihkak Davaları', 'icon': Icons.autorenew},
    {'title': 'Vasiyet İfa Davaları', 'icon': Icons.task_alt},
    {'title': 'Paylaştırma Davaları', 'icon': Icons.pie_chart},
    {'title': 'Konkordato Davaları', 'icon': Icons.request_page},
    {'title': 'Hacizden Şikayet Davaları', 'icon': Icons.report_problem},
    {'title': 'Rehnin Paraya Çevrilmesi Davaları', 'icon': Icons.currency_exchange},
    {'title': 'İflas Erteleme Davaları', 'icon': Icons.schedule},
    {'title': 'Alacak Davası', 'icon': Icons.receipt},
    {'title': 'Ecrimisil Davaları', 'icon': Icons.home_work},
    {'title': 'Kira Bedelinin Tespiti Davaları', 'icon': Icons.calculate},
    {'title': 'Boşaltma Davaları', 'icon': Icons.logout},
    {'title': 'Zorunlu Geçit Hakkı Davaları', 'icon': Icons.route},
    {'title': 'Kaynak Suyu Davaları', 'icon': Icons.water},
    {'title': 'Ağaç Davaları', 'icon': Icons.park},
    {'title': 'Hayvan Zararı Davaları', 'icon': Icons.bug_report},
    {'title': 'Avcılık Davaları', 'icon': Icons.forest},
    {'title': 'Balıkçılık Davaları', 'icon': Icons.phishing},
    {'title': 'Orman Davaları', 'icon': Icons.nature},
    {'title': 'Kıyı Davaları', 'icon': Icons.waves},
    {'title': 'Plaj Davaları', 'icon': Icons.beach_access},
    {'title': 'Turizm Davaları', 'icon': Icons.luggage},
    {'title': 'Ticari Reklam Davaları', 'icon': Icons.campaign},
    {'title': 'Matbaa ve Yayın Davaları', 'icon': Icons.print},
    {'title': 'Eğitim Hukuku Davaları', 'icon': Icons.school},
    {'title': 'Öğrenci Disiplin Davaları', 'icon': Icons.menu_book},
    {'title': 'Akademik Personel Davaları', 'icon': Icons.science},
    {'title': 'Bilirkişilik Davaları', 'icon': Icons.assignment_ind},
    {'title': 'Tenfiz Davaları', 'icon': Icons.verified},
    {'title': 'Tanıma Davaları', 'icon': Icons.check_circle},
    {'title': 'Taşınmaz Satış Vaadi Davaları', 'icon': Icons.sell},
    {'title': 'Ön Alım Hakkı Davaları', 'icon': Icons.first_page},
    {'title': 'Bölge Adliye Mahkemesi Davaları', 'icon': Icons.account_balance},
    {'title': 'Yargıtay Davaları', 'icon': Icons.gavel},
    {'title': 'Anayasa Mahkemesi Davaları', 'icon': Icons.policy},
    {'title': 'AİHM Davaları', 'icon': Icons.public},
    {'title': 'İdari Para Cezası Davaları', 'icon': Icons.receipt},
    {'title': 'Ruhsat İptali Davaları', 'icon': Icons.cancel_presentation},
    {'title': 'Meslek Odası Davaları', 'icon': Icons.work_history},
    {'title': 'Baro Davaları', 'icon': Icons.balance},
    {'title': 'Noterlik Davaları', 'icon': Icons.approval},
    {'title': 'İcra Müdürlüğü Davaları', 'icon': Icons.assignment_turned_in},
    {'title': 'Adli Tıp Davaları', 'icon': Icons.biotech},
    {'title': 'DNA Testi Davaları', 'icon': Icons.fingerprint},
    {'title': 'Koruma Tedbirleri Davaları', 'icon': Icons.verified_user},
    {'title': 'Çocuk Koruma Davaları', 'icon': Icons.child_care},
    {'title': 'Çocuk Suçluları Davaları', 'icon': Icons.report},
    {'title': 'Güvenlik Tedbirleri Davaları', 'icon': Icons.security},
    {'title': 'Müsadere Davaları', 'icon': Icons.block},
    {'title': 'Uzlaştırma Davaları', 'icon': Icons.handshake},
    {'title': 'Kamu Zararı Davaları', 'icon': Icons.error_outline},
    {'title': 'Sahte Belge Davaları', 'icon': Icons.description},
    {'title': 'Dolandırıcılık Davaları', 'icon': Icons.dangerous},
    {'title': 'Hırsızlık Davaları', 'icon': Icons.remove_shopping_cart},
    {'title': 'Cinsel Saldırı Davaları', 'icon': Icons.report_gmailerrorred},
    {'title': 'Şiddet Suçları Davaları', 'icon': Icons.warning},
    {'title': 'Silahlı Suçlar Davaları', 'icon': Icons.dangerous},
    {'title': 'Uyuşturucu Davaları', 'icon': Icons.smoke_free},
    {'title': 'Kaçakçılık Davaları', 'icon': Icons.error},
    {'title': 'Organize Suçlar Davaları', 'icon': Icons.groups},
    {'title': 'Terör Suçları Davaları', 'icon': Icons.emergency},
    {'title': 'Yolsuzluk Davaları', 'icon': Icons.report_problem},
    {'title': 'İhaleye Fesat Karıştırma Davaları', 'icon': Icons.gavel},
    {'title': 'Kara Para Aklama Davaları', 'icon': Icons.attach_money},
    {'title': 'Bilişim Suçları Davaları', 'icon': Icons.computer},
    {'title': 'Telif Hakkı Suçları Davaları', 'icon': Icons.copyright},
    {'title': 'İftira Davaları', 'icon': Icons.speaker_notes_off},
    {'title': 'Yalan Tanıklık Davaları', 'icon': Icons.voice_over_off},
    {'title': 'Kamu Görevlisi Aleyhine Suç Davaları', 'icon': Icons.person_off},
    {'title': 'Trafik Suçları Davaları', 'icon': Icons.directions_car},
    {'title': 'İş Güvenliği Suçları Davaları', 'icon': Icons.health_and_safety},
    {'title': 'Çevre Suçları Davaları', 'icon': Icons.eco},
    {'title': 'Gıda Suçları Davaları', 'icon': Icons.restaurant},
    {'title': 'Hayvan Hakları Suçları Davaları', 'icon': Icons.cruelty_free},
    {'title': 'Fikir ve Sanat Eserleri Suçları', 'icon': Icons.brush},
    {'title': 'Marka İhlali Suçları', 'icon': Icons.label_off},
    {'title': 'Gümrük Suçları', 'icon': Icons.local_shipping},
    {'title': 'Bankacılık Suçları', 'icon': Icons.account_balance},
    {'title': 'Sigortacılık Suçları', 'icon': Icons.policy},
    {'title': 'Sermaye Piyasası Suçları', 'icon': Icons.trending_down},
    {'title': 'Tüketici Suçları', 'icon': Icons.shopping_cart},
    {'title': 'İflas Suçları', 'icon': Icons.trending_down},
    {'title': 'Sınır Ötesi Suçlar', 'icon': Icons.flight_land},
    {'title': 'Çocuk İstismarı Davaları', 'icon': Icons.report_problem},
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_menuItems);
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    
    _searchGlowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchGlowController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = List.from(_menuItems);
      } else {
        _filteredItems = _menuItems
            .where((item) =>
                item['title'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
                    _backgroundController.value * 0.3,
                  )!,
                  const Color(0xFF0A0E21),
                  Color.lerp(
                    const Color(0xFF0A0E21),
                    const Color(0xFF0D47A1),
                    _backgroundController.value * 0.2,
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
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    FadeInLeft(
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: AppTheme.neonBlue.withOpacity(0.5),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FadeInDown(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppTheme.goldColor, Colors.white],
                        ).createShader(bounds),
                        child: const Text(
                          'Hukuki Alanlar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Arama butonu - renk değiştiren gölge
                    FadeInRight(
                      child: AnimatedBuilder(
                        animation: _searchGlowController,
                        builder: (context, child) {
                          final colors = [
                            AppTheme.neonBlue,
                            AppTheme.neonPurple,
                            AppTheme.neonGreen,
                            AppTheme.neonOrange,
                            AppTheme.goldColor,
                            AppTheme.neonPink,
                          ];
                          final colorIndex = (_searchGlowController.value * colors.length).floor() % colors.length;
                          final currentColor = colors[colorIndex];
                          
                          return Container(
                            width: 300,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.5),
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: currentColor.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: currentColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: currentColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _filterItems,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ara...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: currentColor,
                                  size: 22,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.white.withOpacity(0.5),
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          _filterItems('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),

              // Grid of menu items
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final itemIndex = _menuItems.indexOf(_filteredItems[index]);
                    return FadeInUp(
                      delay: Duration(milliseconds: 20 * index),
                      child: _buildMenuItem(
                        _filteredItems[index]['title'],
                        _filteredItems[index]['icon'],
                        itemIndex >= 0 ? itemIndex : index,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, int index) {
    final colors = [
      AppTheme.neonBlue,
      AppTheme.neonGreen,
      AppTheme.neonPurple,
      AppTheme.neonOrange,
      AppTheme.goldColor,
      AppTheme.neonPink,
    ];
    final color = colors[index % colors.length];

    return _HoverMenuItem(
      title: title,
      icon: icon,
      color: color,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LegalCategoryDetailScreen(categoryName: title),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}

class _HoverMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HoverMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<_HoverMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.08 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _isHovered 
                ? widget.color.withOpacity(0.15) 
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: _isHovered 
                  ? widget.color.withOpacity(0.8) 
                  : widget.color.withOpacity(0.3),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: widget.color.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: _isHovered ? 32 : 28,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _isHovered ? 11 : 10,
                    fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                    color: _isHovered ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

