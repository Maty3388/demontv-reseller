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

  final _screens = const [
    ChannelsScreen(),
    ClientsScreen(),
    MoviesScreen(),
    SeriesScreen(),
    LogsScreen(),
    VersionScreen(),
  ];

  final _tabs = const [
    {'icon': Icons.live_tv_outlined, 'label': 'Canales'},
    {'icon': Icons.people_outline,   'label': 'Clientes'},
    {'icon': Icons.movie_outlined,   'label': 'Peliculas'},
    {'icon': Icons.video_library_outlined, 'label': 'Series'},
    {'icon': Icons.history_outlined, 'label': 'Logs'},
    {'icon': Icons.system_update_outlined, 'label': 'Update'},
  ];

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    final r = await AdminApi.getStats();
    if (mounted) setState(() => _stats = r);
  }

  void _logout() {
    AdminApi.clearToken();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminTheme.bg,
    appBar: AppBar(
      backgroundColor: AdminTheme.surface,
      title: Row(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFAA00FF)]), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Text('D+', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 10),
        const Text('DemonTv Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.logout, color: AdminTheme.red), onPressed: _logout),
      ],
    ),
    body: IndexedStack(index: _tab, children: _screens),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(color: AdminTheme.surface, border: Border(top: BorderSide(color: AdminTheme.border, width: 0.5))),
      child: SafeArea(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (i) {
          final t = _tabs[i];
          final sel = i == _tab;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(t['icon'] as IconData, color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, size: 22),
                const SizedBox(height: 2),
                Text(t['label'] as String, style: TextStyle(color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, fontSize: 10, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                if (sel) Container(margin: const EdgeInsets.only(top: 2), width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AdminTheme.cyan)),
              ]),
            ),
          );
        }),
      )),
    ),
  );
}
