import "package:flutter/material.dart";
import "../services/api.dart";
import "../theme/theme.dart";
import "clients_screen.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  int _tab = 0;
  Map _profile = {};
  bool _loading = true;

  final _tabs = const [
    {"icon": Icons.dashboard_outlined, "label": "Inicio"},
    {"icon": Icons.people_outline,     "label": "Clientes"},
  ];

  @override void initState() { super.initState(); _loadProfile(); }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final r = await ResellerApi.getProfile();
    if (mounted) setState(() { _profile = r; _loading = false; });
  }

  void _logout() { ResellerApi.clearToken(); Navigator.pushReplacementNamed(context, "/"); }

  String _rankEmoji(String rank) {
    switch(rank) {
      case "Plata": return "🥈";
      case "Oro": return "🥇";
      case "Diamante": return "💎";
      default: return "🥉";
    }
  }

  Color _rankColor(String rank) {
    switch(rank) {
      case "Plata": return const Color(0xFFB0BEC5);
      case "Oro": return const Color(0xFFFFD700);
      case "Diamante": return const Color(0xFF00CFDD);
      default: return const Color(0xFFCD7F32);
    }
  }

  Widget _buildHome() {
    final rank = _profile["rank"] ?? "Bronce";
    final balance = _profile["balance"] ?? 0;
    final totalSold = _profile["total_sold"] ?? 0;
    final clientsCount = _profile["clients_count"] ?? 0;

    // Progreso al siguiente rango
    final ranks = [
      {"name": "Bronce", "min": 0, "max": 10},
      {"name": "Plata",  "min": 10, "max": 30},
      {"name": "Oro",    "min": 30, "max": 60},
      {"name": "Diamante","min": 60, "max": 60},
    ];
    final currentRank = ranks.firstWhere((r) => r['name'] == rank, orElse: () => ranks[0]);
    final nextRank = ranks.indexOf(currentRank) < ranks.length - 1 ? ranks[ranks.indexOf(currentRank) + 1] : null;
    final progress = nextRank != null ? (totalSold - (currentRank['min'] as int)) / ((nextRank['min'] as int) - (currentRank['min'] as int)) : 1.0;

    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      // Rango card
      Container(width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_rankColor(rank).withOpacity(0.8), _rankColor(rank).withOpacity(0.4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: _rankColor(rank).withOpacity(0.4), blurRadius: 16, offset: const Offset(0,4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(_rankEmoji(rank), style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rank, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(_profile['name'] ?? _profile["email"] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ]),
          if (nextRank != null) ...[
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Progreso a \${nextRank['name']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text("$totalSold / ${nextRank['min']} vendidos", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8)),
          ],
        ])),
      const SizedBox(height: 16),
      // Stats
      Row(children: [
        Expanded(child: _StatCard("Coins", "\$balance", Icons.monetization_on, const Color(0xFF6C3DE0))),
        const SizedBox(width: 12),
        Expanded(child: _StatCard("Clientes", "\$clientsCount", Icons.people, AdminTheme.cyan)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard("Vendidos", "\$totalSold", Icons.bar_chart, AdminTheme.green)),
      ]),
    ]));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0A0F),
    appBar: AppBar(backgroundColor: AdminTheme.surface, elevation: 0,
      title: const Text("DemonTv Revendedor", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [IconButton(icon: const Icon(Icons.logout, color: AdminTheme.textSecondary), onPressed: _logout)]),
    body: _loading ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
      : IndexedStack(index: _tab, children: [_buildHome(), const ClientsScreen()]),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(color: AdminTheme.surface, border: Border(top: BorderSide(color: AdminTheme.border, width: 0.5))),
      child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            final t = _tabs[i];
            final sel = _tab == i;
            return GestureDetector(onTap: () => setState(() => _tab = i),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(t["icon"] as IconData, color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, size: 24),
                const SizedBox(height: 4),
                Text(t["label"] as String, style: TextStyle(color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, fontSize: 11, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              ]));
          }))))),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3), width: 1)),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
    ]));
}
