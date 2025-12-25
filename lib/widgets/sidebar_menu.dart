import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SidebarMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  // "Legendary" Color Palette
  static const Color _bgDark = Color(0xFF0F172A); // Slate 900
  static const Color _bgCard = Color(0xFF1E293B); // Slate 800
  static const Color _accentGold = Color(0xFFD4AF37); // Metallic Gold
  static const Color _textWhite = Color(0xFFF8FAFC); // Slate 50
  static const Color _textGrey = Color(0xFF94A3B8); // Slate 400

  final List<SidebarMenuItem> _menuItems = [
    SidebarMenuItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Ana Sayfa',
      color: _accentGold,
    ),
    SidebarMenuItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Müvekkiller',
      color: _accentGold,
    ),
    SidebarMenuItem(
      icon: Icons.gavel_outlined,
      activeIcon: Icons.gavel,
      label: 'Duruşmalar',
      color: _accentGold,
    ),
    SidebarMenuItem(
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
      label: 'Ödemeler',
      color: _accentGold,
    ),
    SidebarMenuItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      label: 'TCK Maddeleri',
      color: _accentGold,
    ),
    SidebarMenuItem(
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance,
      label: 'Bankalar',
      color: _accentGold,
    ),
    SidebarMenuItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Ayarlar',
      color: _accentGold,
    ),
    SidebarMenuItem(
      icon: Icons.person_add_outlined,
      activeIcon: Icons.person_add,
      label: 'Yeni Müvekkil',
      color: const Color(0xFF2ECC71), // Yeşil renk
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 240 : 72,
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Logo Area
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isExpanded ? 16 : 10,
              vertical: 14,
            ),
            child: Row(
              mainAxisAlignment: _isExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (_isExpanded)
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _accentGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _accentGold.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.balance,
                            color: _accentGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AVUKAT',
                                style: TextStyle(
                                  color: _textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                'PORTAL',
                                style: TextStyle(
                                  color: _accentGold,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 10,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: _textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) => _buildMenuItem(index),
            ),
          ),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildLogoutButton(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    final item = _menuItems[index];
    final isSelected = widget.selectedIndex == index;

    final tile = InkWell(
      onTap: () => widget.onItemSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 14 : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? _accentGold.withOpacity(0.9) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              _isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? _accentGold : _textGrey,
              size: 20,
            ),
            if (_isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? _textWhite : _textGrey,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: _isExpanded ? tile : Tooltip(message: item.label, child: tile),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: widget.onLogout,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 14 : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red.withOpacity(0.1),
          border: Border.all(
            color: Colors.red.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: _isExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red.shade400,
              size: 20,
            ),
            if (_isExpanded) ...[
              const SizedBox(width: 12),
              Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SidebarMenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  SidebarMenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
