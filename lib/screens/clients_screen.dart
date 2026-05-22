import "package:flutter/material.dart";
import "../services/api.dart";
import "../theme/theme.dart";

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override State<ClientsScreen> createState() => _ClientsState();
}

class _ClientsState extends State<ClientsScreen> {
  List _clients = [];
  bool _loading = true;
  final _search = TextEditingController();
  List _filtered = [];

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ResellerApi.getClients();
    if (!mounted) return;
    final clients = r["clients"] ?? [];
    setState(() { _clients = clients; _filtered = clients; _loading = false; });
  }

  void _filter(String q) {
    setState(() => _filtered = q.isEmpty ? _clients : _clients.where((c) => (c["email"] ?? "").toLowerCase().contains(q.toLowerCase())).toList());
  }

  String _getId(Map c) => (c["_id"] ?? c["id"] ?? "").toString().replaceAll("ObjectId(", "").replaceAll(")", "").replaceAll("'", "").trim();

  @override
  Widget build(BuildContext context) => _loading
    ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
    : Column(children: [
        Padding(padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(child: TextField(controller: _search, onChanged: _filter,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Buscar cliente...", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary, size: 20),
                filled: true, fillColor: AdminTheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10)))),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Nuevo", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => _showAddDialog(context)),
          ])),
        Expanded(child: _filtered.isEmpty
          ? const Center(child: Text("No hay clientes", style: TextStyle(color: AdminTheme.textSecondary)))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.1),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final c = _filtered[i];
                final id = _getId(c);
                final days = c["daysLeft"] ?? -1;
                final expired = c["isExpired"] == true;
                final expiringSoon = !expired && days <= 5;
                final statusColor = expired ? AdminTheme.red : expiringSoon ? AdminTheme.gold : AdminTheme.green;
                return Container(
                  decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.2), width: 1)),
                  child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 12, backgroundColor: statusColor.withOpacity(0.15),
                        child: Icon(Icons.person, color: statusColor, size: 12)),
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(expired ? "Vencido" : expiringSoon ? "\$days días" : "Activo",
                          style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold))),
                    ]),
                    const SizedBox(height: 6),
                    Text(c["email"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(c["subscription_end"] ?? "N/A", style: TextStyle(color: statusColor, fontSize: 10)),
                    const Spacer(),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      _SmallBtn(icon: Icons.calendar_month, color: AdminTheme.cyan, onTap: () => _showRenewDialog(ctx, id, c["email"])),
                    ]),
                  ])));
              })),
      ]);

  void _showAddDialog(BuildContext ctx) {
    final email = TextEditingController();
    final pass  = TextEditingController();
    int months = 1;
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text("Nuevo Cliente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: email, style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(hintText: "Email", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surfaceAlt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
        const SizedBox(height: 8),
        TextField(controller: pass, style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(hintText: "Contraseña", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surfaceAlt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.remove_circle, color: AdminTheme.cyan), onPressed: () { if (months > 1) ss(() => months--); }),
          Text("\$months mes\${months > 1 ? "es" : ""}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add_circle, color: AdminTheme.cyan), onPressed: () => ss(() => months++)),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black),
          onPressed: () async {
            if (email.text.isNotEmpty && pass.text.isNotEmpty) {
              Navigator.pop(c);
              final r = await ResellerApi.createClient(email.text.trim(), pass.text.trim(), months);
              if (r["success"] == true) _load();
              else if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(r["error"] ?? "Error"), backgroundColor: AdminTheme.red));
            }
          }, child: const Text("CREAR")),
      ])));
  }

  void _showRenewDialog(BuildContext ctx, String id, String email) {
    int months = 1;
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: Text("Renovar: \$email", style: const TextStyle(color: Colors.white, fontSize: 13)),
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: const Icon(Icons.remove_circle, color: AdminTheme.cyan), onPressed: () { if (months > 1) ss(() => months--); }),
        Text("\$months", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle, color: AdminTheme.cyan), onPressed: () => ss(() => months++)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black),
          onPressed: () async { Navigator.pop(c); await ResellerApi.extendClient(id, months: months); _load(); },
          child: const Text("RENOVAR")),
      ])));
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallBtn({super.key, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, color: color, size: 14)));
}
