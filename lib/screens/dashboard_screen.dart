import 'sub_resellers_screen.dart';
import 'chat_screen.dart';
import 'historial_screen.dart';
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

  List<Map> get _tabs {
    final rank = _profile["rank"] ?? "Bronce";
    final tabs = [
      {"icon": Icons.dashboard_outlined, "label": "Inicio"},
      {"icon": Icons.people_outline,     "label": "Clientes"},
    ];
    if (rank != "Bronce") tabs.add({"icon": Icons.group_add_outlined, "label": "Revendedores"});
    tabs.add({"icon": Icons.history_outlined, "label": "Historial"});
    tabs.add({"icon": Icons.chat_outlined, "label": "Chat"});
    return tabs;
  }

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

  List<Widget> _buildScreens() {
    final rank = _profile["rank"] ?? "Bronce";
    final screens = <Widget>[_buildHome(), const ClientsScreen()];
    if (rank != "Bronce") screens.add(const SubResellersScreen());
    screens.add(const HistorialScreen());
    screens.add(const ChatScreen());
    return screens;
  }

  Widget _buildHome() {
    final rank = _profile["rank"] ?? "Bronce";
    final balance = _profile["balance"] ?? 0;

    return SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [
      // Card principal
      Container(width: double.infinity, padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6C3DE0), Color(0xFFB03DE0), Color(0xFFE03D8F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: const Color(0xFF6C3DE0).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 6))]),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Saldo", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text(r"$", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text("$balance", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ]),
            const Text("Coins disponibles", style: TextStyle(color: Colors.white60, fontSize: 11)),
          ])),
          Container(width: 1, height: 60, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 14)),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_rankEmoji(rank), style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(rank, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(_profile["name"] ?? _profile["email"] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ])),
      const SizedBox(height: 14),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8,
        children: [
          _StatCard("Activas", "${_profile["activos"] ?? 0}", Icons.check_circle_outline, AdminTheme.green),
          _StatCard("Por Expirar", "${_profile["por_vencer"] ?? 0}", Icons.warning_amber_outlined, AdminTheme.gold),
          _StatCard("Expiradas", "${_profile["vencidos"] ?? 0}", Icons.cancel_outlined, AdminTheme.red),
          _StatCard("Revendedores", "${_profile["sub_resellers"] ?? 0}", Icons.group_outlined, const Color(0xFF6C3DE0)),
        ]),
      const SizedBox(height: 14),
      TextField(
        style: const TextStyle(color: Colors.white, fontSize: 13),
        onChanged: (q) { setState(() {}); },
        decoration: InputDecoration(
          hintText: "Buscar cliente...",
          hintStyle: const TextStyle(color: AdminTheme.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary, size: 20),
          filled: true, fillColor: AdminTheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10))),
    ]));
  }


  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvoked: (didPop) async {
      if (_tab != 0) { setState(() => _tab = 0); return; }
    },
    child: Scaffold(
    backgroundColor: const Color(0xFF0A0A0F),
    appBar: AppBar(elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6C3DE0), Color(0xFFB03DE0), Color(0xFFE03D8F)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
      leading: Container(margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: const Center(child: Text("F", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)))),
      centerTitle: true,
      title: const Text("Bienvenido al Panel\nFluxTv Reseller", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.white70), onPressed: _logout)]),
    body: _loading ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
      : KeyedSubtree(key: ValueKey(_tab), child: _buildScreens()[_tab]),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(color: AdminTheme.surface, border: Border(top: BorderSide(color: AdminTheme.border, width: 0.5))),
      child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            final t = _tabs[i];
            final sel = _tab == i;
            return GestureDetector(onTap: () { setState(() => _tab = i); },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(t["icon"] as IconData, color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, size: 24),
                const SizedBox(height: 4),
                Text(t["label"] as String, style: TextStyle(color: sel ? AdminTheme.cyan : AdminTheme.textSecondary, fontSize: 11, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              ]));
          }))))),
    ));
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
