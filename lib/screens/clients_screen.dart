import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/database_service.dart';
import 'add_client_screen.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final Color _background = const Color(0xFF0F172A);
  final Color _cardColor = const Color(0xFF1E293B);

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasChanges = false;
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    final items = await _dbService.getAllClients();
    if (!mounted) return;
    setState(() {
      _clients = items;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await _loadClients();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _onAddClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClientScreen()),
    );

    if (result != null) {
      _hasChanges = true;
      await _loadClients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yeni müvekkil eklendi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openDetail(Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailScreen(
          clientData: {
            'id': client.id,
            'tc_number': client.tcNo,
            'full_name': client.fullName,
          },
        ),
      ),
    );
  }

  void _popWithResult() {
    Navigator.pop(context, _hasChanges);
  }

  Future<bool> _handleWillPop() async {
    _popWithResult();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _cardColor,
          title: Text('Müvekkiller (${_clients.length})'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _popWithResult,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _refresh,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _onAddClient,
          backgroundColor: const Color(0xFF3B82F6),
          icon: const Icon(Icons.person_add),
          label: const Text('Yeni Müvekkil Ekle'),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search, size: 64, color: Colors.white70),
            const SizedBox(height: 12),
            const Text(
              'Kayıtlı müvekkil bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onAddClient,
              icon: const Icon(Icons.person_add),
              label: const Text('İlk müvekkili ekle'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF3B82F6),
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.0,
            ),
            itemCount: _clients.length,
            itemBuilder: (context, index) {
              final client = _clients[index];
              return _buildClientCard(client);
            },
          );
        },
      ),
    );
  }

  Widget _buildClientCard(Client client) {
    final remaining = client.remainingAmount;
    final remainingColor = remaining >= 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return InkWell(
      onTap: () => _openDetail(client),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: client.photoUrl != null && client.photoUrl!.isNotEmpty
                      ? Image.network(
                          client.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 22),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _miniChip(Icons.badge, client.tcNo),
                          _miniChip(Icons.phone, client.phoneNumber),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Anlaşılan',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                    Text(
                      _formatCurrency(client.agreedAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kalan',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                    Text(
                      _formatCurrency(remaining),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: remainingColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.6),
                          remainingColor.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _miniChip(Icons.arrow_forward_ios, 'Detay'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0)} ₺';
  }
}
