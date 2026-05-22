import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override State<ClientsScreen> createState() => _ClientsState();
}

class _ClientsState extends State<ClientsScreen> {
  List _clients = [];
  List _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();
  Map _stats = {};

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await AdminApi.getClients();
    final s = await AdminApi.getStats();
    if (!mounted) return;
    final clients = r["clients"] ?? [];
    setState(() { _clients = clients; _filtered = clients; _stats = s; _loading = false; });
  }

  void _filter(String q) {
    setState(() => _filtered = q.isEmpty ? _clients : _clients.where((c) => (c["email"] ?? "").toLowerCase().contains(q.toLowerCase())).toList());
  }

  String _getId(Map c) => (c["_id"] ?? c["id"] ?? "").toString().replaceAll("ObjectId(", "").replaceAll(")", "").replaceAll("'", "").trim();

  int _daysLeft(Map c) => DateTime.tryParse(c["subscription_end"] ?? "") != null ? DateTime.parse(c["subscription_end"]).difference(DateTime.now()).inDays : -1;

  @override
  Widget build(BuildContext context) => _loading
    ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
    : RefreshIndicator(onRefresh: _load, color: AdminTheme.cyan,
        child: Column(children: [
          // Balance card
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6C3DE0), Color(0xFFB03DE0), Color(0xFFE03D8F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: const Color(0xFF6C3DE0).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 6))]),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.monetization_on, color: Colors.white, size: 32)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Coins", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                Row(children: [
                  Text("${_stats['balance'] ?? 0}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  const Icon(Icons.toll, color: Colors.white70, size: 20),
                ]),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text("${_stats['activos'] ?? 0} activos", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(height: 4),
                Text("${_stats['total'] ?? 0} total", style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ]),
            ])),
          // Buscador
          Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(controller: _search, onChanged: _filter,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Buscar cliente...", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary, size: 20),
                suffixIcon: _search.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AdminTheme.textSecondary, size: 18), onPressed: () { _search.clear(); _filter(''); }) : null,
                filled: true, fillColor: AdminTheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10)))),
          const SizedBox(height: 10),
          // Lista clientes
          Expanded(child: _filtered.isEmpty
            ? const Center(child: Text("No hay clientes", style: TextStyle(color: AdminTheme.textSecondary)))
            : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.4),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final c = _filtered[i];
                  final id = _getId(c);
                  final blocked = c["blocked"] == true;
                  final days = _daysLeft(c);
                  final expired = days < 0;
                  final expiringSoon = days >= 0 && days <= 5;
                  Color statusColor = expired ? AdminTheme.red : expiringSoon ? AdminTheme.gold : AdminTheme.green;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AdminTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: blocked ? AdminTheme.red.withOpacity(0.3) : statusColor.withOpacity(0.2), width: 1)),
                    child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: blocked ? AdminTheme.red.withOpacity(0.2) : statusColor.withOpacity(0.15),
                        child: Icon(blocked ? Icons.block : Icons.person, color: blocked ? AdminTheme.red : statusColor, size: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c["email"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.calendar_today, size: 10, color: statusColor),
                          const SizedBox(width: 4),
                          Text(expired ? "Vencido" : expiringSoon ? "Vence en $days días" : "Vence: ${c["subscription_end"] ?? "N/A"}",
                            style: TextStyle(color: statusColor, fontSize: 11)),
                        ]),
                      ])),
                      // Botones
                      IconButton(icon: const Icon(Icons.calendar_month, color: AdminTheme.cyan, size: 20), tooltip: "Renovar",
                        onPressed: () => _showRenewDialog(ctx, id, c["email"])),
                      IconButton(icon: Icon(blocked ? Icons.lock_open : Icons.lock_outline, color: blocked ? AdminTheme.green : AdminTheme.gold, size: 20),
                        onPressed: () async { await AdminApi.updateClient(id, blocked: !blocked); _load(); }),
                      IconButton(icon: const Icon(Icons.phonelink_erase, color: AdminTheme.textSecondary, size: 20), tooltip: "Quitar dispositivo",
                        onPressed: () async { await AdminApi.removeDevice(id); _load(); }),
                      IconButton(icon: const Icon(Icons.delete_outline, color: AdminTheme.red, size: 20),
                        onPressed: () => _confirmDelete(ctx, id, c["email"])),
                    ])));
                })),
        ]));

  void _showRenewDialog(BuildContext ctx, String id, String email) {
    int months = 1;
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: Text("Renovar: $email", style: const TextStyle(color: Colors.white, fontSize: 14)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Meses a agregar:", style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.remove_circle, color: AdminTheme.cyan), onPressed: () { if (months > 1) ss(() => months--); }),
          Text("$months", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add_circle, color: AdminTheme.cyan), onPressed: () => ss(() => months++)),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black),
          onPressed: () async { Navigator.pop(c); await AdminApi.extendClient(id, months: months); _load(); },
          child: const Text("RENOVAR")),
      ])));
  }


  void _showPasswordDialog(BuildContext ctx, String id, String email) {
    final ctrl = TextEditingController();
    bool show = false;
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: Text("Cambiar contraseña: $email", style: const TextStyle(color: Colors.white, fontSize: 13)),
      content: TextField(controller: ctrl, obscureText: !show,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: "Nueva contraseña", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
          filled: true, fillColor: AdminTheme.surfaceAlt,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: AdminTheme.textSecondary, size: 18),
            onPressed: () => ss(() => show = !show)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black),
          onPressed: () async { if (ctrl.text.isNotEmpty) { Navigator.pop(c); await AdminApi.updateClient(id, password: ctrl.text); _load(); } },
          child: const Text("GUARDAR")),
      ])));
  }
  void _confirmDelete(BuildContext ctx, String id, String email) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text("Eliminar cliente", style: TextStyle(color: Colors.white)),
      content: Text("¿Eliminar $email?", style: const TextStyle(color: AdminTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.red, foregroundColor: Colors.white),
          onPressed: () async { Navigator.pop(c); await AdminApi.deleteClient(id); _load(); },
          child: const Text("ELIMINAR")),
      ]));
  
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(margin: const EdgeInsets.only(left: 4), padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, color: color, size: 14)));
}
