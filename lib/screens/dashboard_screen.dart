import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';
import 'channels_screen.dart';
import 'clients_screen.dart';
import 'movies_screen.dart';
import 'series_screen.dart';
import 'logs_screen.dart';
import 'version_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  int _tab = 0;
  Map _stats = {};
  bool _loadingStats = true;

  final _tabs = const [
    {"icon": Icons.bar_chart_outlined,       "label": "Stats"},
    {"icon": Icons.live_tv_outlined,         "label": "Canales"},
    {"icon": Icons.people_outline,           "label": "Clientes"},
    {"icon": Icons.movie_outlined,           "label": "Peliculas"},
    {"icon": Icons.video_library_outlined,   "label": "Series"},
    {"icon": Icons.history_outlined,         "label": "Logs"},
    {"icon": Icons.system_update_outlined,   "label": "Update"},
  ];

  @override void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    final r = await AdminApi.getStats();
    if (mounted) setState(() { _stats = r; _loadingStats = false; });
  }

  void _logout() { AdminApi.clearToken(); Navigator.pushReplacementNamed(context, "/"); }

  Widget _buildStats() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Resumen", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      // Creditos
      Row(children: [
        _StatCard("Balance", "${_stats["balance"] ?? 0}", Icons.account_balance_wallet_outlined, AdminTheme.cyan),
        const SizedBox(width: 12),
        _StatCard("Extras", "${_stats["extras"] ?? 0}", Icons.add_circle_outline, AdminTheme.gold),
        const SizedBox(width: 12),
        _StatCard("Spins", "${_stats["spins"] ?? 0}", Icons.refresh, AdminTheme.green),
      ]),
      const SizedBox(height: 12),
      // Usuarios
      const Text("Usuarios", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        _StatCard("Total", "${_stats["total"] ?? 0}", Icons.people_outline, Colors.white),
        const SizedBox(width: 12),
        _StatCard("Activos", "${_stats["activos"] ?? 0}", Icons.check_circle_outline, AdminTheme.green),
        const SizedBox(width: 12),
        _StatCard("Vencidos", "${_stats["vencidos"] ?? 0}", Icons.error_outline, AdminTheme.red),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _StatCard("Por Vencer", "${_stats["porVencer"] ?? 0}", Icons.warning_outlined, AdminTheme.gold),
        const SizedBox(width: 12),
        _StatCard("Bloqueados", "${_stats["bloqueados"] ?? 0}", Icons.block, AdminTheme.red),
        const SizedBox(width: 12),
        _StatCard("Viendo", "${_stats["watching"] ?? 0}", Icons.play_circle_outline, AdminTheme.cyan),
      ]),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text("Actualizar"),
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.surface, foregroundColor: AdminTheme.cyan),
          onPressed: _loadStats)),
    ]),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminTheme.bg,
    appBar: AppBar(
      backgroundColor: AdminTheme.surface,
      title: Row(children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFAA00FF)]), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text("D+", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 8),
        const Text("DemonTv Admin", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ]),
      actions: [IconButton(icon: const Icon(Icons.logout, color: AdminTheme.red), onPressed: _logout)],
    ),
    body: IndexedStack(index: _tab, children: [
      _loadingStats ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan)) : _buildStats(),
      const ChannelsScreen(),
      const ClientsScreen(),
      const MoviesScreen(),
      const SeriesScreen(),
      const LogsScreen(),
      const VersionScreen(),
    ]),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(color: AdminTheme.surface, border: Border(top: BorderSide(color: AdminTheme.border, width: 0.5))),
      child: SafeArea(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (i) {
          final t = _tabs[i];
          final sel = i == _tab;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(t["icon"] as IconData, color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, size: 20),
                const SizedBox(height: 2),
                Text(t["label"] as String, style: TextStyle(color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, fontSize: 9, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                if (sel) Container(margin: const EdgeInsets.only(top: 2), width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AdminTheme.cyan)),
              ])),
          );
        }),
      )),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AdminTheme.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
    ]),
  ));
}

class AppTheme {
  static const textSecondary = Color(0xFF8E8E93);
}
