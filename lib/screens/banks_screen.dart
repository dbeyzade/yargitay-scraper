import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'webview_screen.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({
    super.key,
    this.onMinimize,
  });

  final void Function(MinimizedBrowser)? onMinimize;

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBanks = [];
  String _searchQuery = '';

  final List<Map<String, dynamic>> _banks = [
    {
      'name': 'Ziraat Bankası',
      'url': 'https://www.ziraatbank.com.tr',
      'emoji': '🏦',
      'color': Color(0xFF009639),
    },
    {
      'name': 'İş Bankası',
      'url': 'https://www.isbank.com.tr',
      'emoji': '🏛️',
      'color': Color(0xFF004B93),
    },
    {
      'name': 'Garanti BBVA',
      'url': 'https://www.garantibbva.com.tr',
      'emoji': '🏢',
      'color': Color(0xFF00A650),
    },
    {
      'name': 'Akbank',
      'url': 'https://www.akbank.com',
      'emoji': '🏪',
      'color': Color(0xFFE30A17),
    },
    {
      'name': 'Yapı Kredi',
      'url': 'https://www.yapikredi.com.tr',
      'emoji': '🏬',
      'color': Color(0xFF004B8D),
    },
    {
      'name': 'Vakıfbank',
      'url': 'https://www.vakifbank.com.tr',
      'emoji': '🏦',
      'color': Color(0xFF003D7A),
    },
    {
      'name': 'Halkbank',
      'url': 'https://www.halkbank.com.tr',
      'emoji': '🏛️',
      'color': Color(0xFFE30A17),
    },
    {
      'name': 'Denizbank',
      'url': 'https://www.denizbank.com',
      'emoji': '🌊',
      'color': Color(0xFF0071BC),
    },
    {
      'name': 'QNB Finansbank',
      'url': 'https://www.qnbfinansbank.com',
      'emoji': '💼',
      'color': Color(0xFF8B1874),
    },
    {
      'name': 'TEB',
      'url': 'https://www.teb.com.tr',
      'emoji': '🏢',
      'color': Color(0xFF00843D),
    },
    {
      'name': 'ING',
      'url': 'https://www.ing.com.tr',
      'emoji': '🦁',
      'color': Color(0xFFFF6200),
    },
    {
      'name': 'Kuveyt Türk',
      'url': 'https://www.kuveytturk.com.tr',
      'emoji': '🕌',
      'color': Color(0xFF009639),
    },
    {
      'name': 'Albaraka Türk',
      'url': 'https://www.albaraka.com.tr',
      'emoji': '🕋',
      'color': Color(0xFF00A651),
    },
    {
      'name': 'Türkiye Finans',
      'url': 'https://www.turkiyefinans.com.tr',
      'emoji': '🏦',
      'color': Color(0xFF004B8D),
    },
    {
      'name': 'Aktif Bank',
      'url': 'https://www.aktifbank.com.tr',
      'emoji': '⚡',
      'color': Color(0xFFFF6B35),
    },
    {
      'name': 'Burgan Bank',
      'url': 'https://www.burgan.com.tr',
      'emoji': '🏪',
      'color': Color(0xFF0066B3),
    },
    {
      'name': 'Odeabank',
      'url': 'https://www.odeabank.com.tr',
      'emoji': '💳',
      'color': Color(0xFFE30613),
    },
    {
      'name': 'Şekerbank',
      'url': 'https://www.sekerbank.com.tr',
      'emoji': '🍬',
      'color': Color(0xFF009FE3),
    },
    {
      'name': 'HSBC',
      'url': 'https://www.hsbc.com.tr',
      'emoji': '🏦',
      'color': Color(0xFFDB0011),
    },
    {
      'name': 'Anadolubank',
      'url': 'https://www.anadolubank.com.tr',
      'emoji': '🏛️',
      'color': Color(0xFF0054A6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredBanks = _banks;
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterBanks(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBanks = _banks;
      } else {
        _filteredBanks = _banks
            .where((bank) =>
                bank['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildBanksGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3C),
            const Color(0xFF0A0E21),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00BCD4).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.account_balance, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BANKALAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${_banks.length} Banka',
                style: TextStyle(
                  color: Color(0xFF00BCD4),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? Color(0xFF00BCD4)
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _searchQuery.isNotEmpty
                  ? Color(0xFF00BCD4).withOpacity(0.2)
                  : Colors.transparent,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterBanks,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Banka ara...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: Icon(Icons.search, color: Color(0xFF00BCD4)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.5)),
                    onPressed: () {
                      _searchController.clear();
                      _filterBanks('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildBanksGrid() {
    if (_filteredBanks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'Banka bulunamadı',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredBanks.length,
      itemBuilder: (context, index) {
        final bank = _filteredBanks[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: _buildBankCard(bank),
        );
      },
    );
  }

  Widget _buildBankCard(Map<String, dynamic> bank) {
    final color = bank['color'] as Color;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              url: bank['url'],
              title: bank['name'],
              themeColor: color,
              onMinimize: widget.onMinimize,
            ),
          ),
        );
      },
      child: Container(
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
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glow effect
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          bank['emoji'],
                          style: const TextStyle(fontSize: 42),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      bank['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
