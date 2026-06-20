import "package:flutter/material.dart";
import "package:flutter/services.dart";
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
  String _statusFilter = 'todos';

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ResellerApi.getClients();
    if (!mounted) return;
    final clients = r["clients"] ?? [];
    setState(() { _clients = clients; _loading = false; }); _applyFilter();
  }

  void _filter(String q) { _applyFilter(search: q); }

  void _applyFilter({String? search}) {
    final q = search ?? _search.text;
    setState(() => _filtered = _clients.where((c) {
      final matchSearch = q.isEmpty || (c["email"] ?? "").toLowerCase().contains(q.toLowerCase());
      final days = c["daysLeft"] ?? -1;
      final expired = c["isExpired"] == true;
      final matchStatus = _statusFilter == 'todos' ||
        (_statusFilter == 'activos' && !expired && days > 5) ||
        (_statusFilter == 'por_vencer' && !expired && days <= 5) ||
        (_statusFilter == 'vencidos' && expired);
      return matchSearch && matchStatus;
    }).toList());
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
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            _FilterChip('Todos', 'todos', _statusFilter, (v) { setState(() => _statusFilter = v); _applyFilter(); }),
            const SizedBox(width: 8),
            _FilterChip('Activos', 'activos', _statusFilter, (v) { setState(() => _statusFilter = v); _applyFilter(); }),
            const SizedBox(width: 8),
            _FilterChip('Por vencer', 'por_vencer', _statusFilter, (v) { setState(() => _statusFilter = v); _applyFilter(); }),
            const SizedBox(width: 8),
            _FilterChip('Vencidos', 'vencidos', _statusFilter, (v) { setState(() => _statusFilter = v); _applyFilter(); }),
          ])),
        const SizedBox(height: 8),
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
                        child: Text(expired ? "Vencido" : (c["isDemo"] == true) ? "$days h" : expiringSoon ? "$days días" : "Activo",
                          style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold))),
                    ]),
                    const SizedBox(height: 6),
                    Text(c["email"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(c["subscription_end"] ?? "N/A", style: TextStyle(color: statusColor, fontSize: 10)),
                    const Spacer(),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      _SmallBtn(icon: Icons.info_outline, color: const Color(0xFF6C3DE0), onTap: () => _showDetailDialog(ctx, id, c)),
                      _SmallBtn(icon: Icons.calendar_month, color: AdminTheme.cyan, onTap: () => _showRenewDialog(ctx, id, c["email"])),
                      _SmallBtn(icon: Icons.edit, color: AdminTheme.gold, onTap: () => _showEditDialog(ctx, id, c["email"])),
                      _SmallBtn(icon: Icons.phonelink_erase, color: AdminTheme.textSecondary, onTap: () => _removeDevice(ctx, id)),
                      _SmallBtn(icon: Icons.delete_forever, color: AdminTheme.red, onTap: () => _deleteClient(ctx, id, c["email"] ?? "")),
                    ]),
                  ])));
              })),
      ]);

  void _showAddDialog(BuildContext ctx) {
    final email = TextEditingController();
    final pass  = TextEditingController();
    int months = 1;
    bool isDemo = false;
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text("Nuevo Cliente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Email con boton generar
        Row(children: [
          Expanded(child: TextField(controller: email, style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(hintText: "Email", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
              filled: true, fillColor: AdminTheme.surfaceAlt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)))),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C3DE0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              final rand = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
              ss(() {
                email.text = "user$rand@fluxtv.tv";
                pass.text = "pass$rand";
              });
            },
            child: const Text("🎲", style: TextStyle(fontSize: 16))),
        ]),
        const SizedBox(height: 8),
        // Password
        TextField(controller: pass, style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(hintText: "Contraseña", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surfaceAlt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10))),
        const SizedBox(height: 14),
        // Botones de duracion
        Wrap(spacing: 6, runSpacing: 6, children: [
          _DurBtn("Demo 1h", 0, months == 0, () => ss(() { months = 0; isDemo = true; })),
          _DurBtn("1 Mes",   1, months == 1 && !isDemo, () => ss(() { months = 1; isDemo = false; })),
          _DurBtn("3 Meses", 3, months == 3, () => ss(() { months = 3; isDemo = false; })),
          _DurBtn("6 Meses", 6, months == 6, () => ss(() { months = 6; isDemo = false; })),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () async {
            if (email.text.isNotEmpty && pass.text.isNotEmpty) {
              Navigator.pop(c);
              final r = await ResellerApi.createClient(email.text.trim(), pass.text.trim(), isDemo ? 0 : months, isDemo: isDemo);
              if (r["success"] == true) {
                final text = "📺FluxTv📺\nCliente Creado\n\nEmail: ${email.text.trim()}\nContraseña: ${pass.text.trim()}";
                await Clipboard.setData(ClipboardData(text: text));
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("✅ Credenciales copiadas"), backgroundColor: Color(0xFF4CAF50)));
                _load();
              } else if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(r["error"] ?? "Error"), backgroundColor: AdminTheme.red));
              }
            }
          }, child: const Text("CREAR", style: TextStyle(fontWeight: FontWeight.bold))),
      ])));
  }



  void _showDetailDialog(BuildContext ctx, String id, Map client) {
    showModalBottomSheet(context: ctx, backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person_outline, color: Color(0xFF6C3DE0), size: 20),
          const SizedBox(width: 8),
          const Text('Detalle del cliente', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        _DetailRow('Email', client['email'] ?? ''),
        _DetailRow('Vencimiento', client['subscription_end'] ?? 'N/A'),
        _DetailRow('Dias restantes', '${client['daysLeft'] ?? 0} días'),
        _DetailRow('Estado', client['isExpired'] == true ? 'Vencido' : 'Activo'),
        _DetailRow('Bloqueado', client['blocked'] == true ? 'Sí' : 'No'),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Icons.content_copy, size: 16),
          label: const Text('Copiar credenciales'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C3DE0), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: '📺FluxTv📺\nEmail: ${client['email']}\nApp: https://bit.ly/fluxtv'));
            if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('✅ Copiado'), backgroundColor: Color(0xFF4CAF50))); }
          })),
      ])));
  }

  void _showEditDialog(BuildContext ctx, String id, String email) {
    final newEmail = TextEditingController(text: email);
    final newPass  = TextEditingController();
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text("Editar cuenta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: newEmail, style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(hintText: "Email", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surfaceAlt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
        const SizedBox(height: 8),
        TextField(controller: newPass, style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(hintText: "Nueva contraseña (vacío = no cambiar)", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surfaceAlt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black),
          onPressed: () async {
            Navigator.pop(c);
            await ResellerApi.updateClient(id, email: newEmail.text.trim(), password: newPass.text.isEmpty ? null : newPass.text.trim());
            _load();
          }, child: const Text("GUARDAR")),
      ]));
  }

  Future<void> _deleteClient(BuildContext ctx, String id, String email) async {
    final confirm = await showDialog<bool>(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text("Eliminar cliente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text("¿Eliminar la cuenta de $email? Esta acción no se puede deshacer.", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.red, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(c, true), child: const Text("ELIMINAR")),
      ]));
    if (confirm == true) {
      await ResellerApi.deleteClient(id);
      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Cliente eliminado"), backgroundColor: AdminTheme.red));
      _load();
    }
  }

  Future<void> _removeDevice(BuildContext ctx, String id) async {
    final confirm = await showDialog<bool>(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text("Eliminar dispositivo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: const Text("Se desvinculará el dispositivo de esta cuenta.", style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.red, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(c, true), child: const Text("ELIMINAR")),
      ]));
    if (confirm == true) {
      await ResellerApi.removeDevice(id);
      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Dispositivo eliminado"), backgroundColor: AdminTheme.green));
      _load();
    }
  }

  void _showRenewDialog(BuildContext ctx, String id, String email) {
    int months = 1;
    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: Text("Renovar cuenta", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(email, style: const TextStyle(color: AdminTheme.cyan, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 14),
        const Text("Seleccionar meses:", style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _DurBtn("1 Mes",   1, months == 1, () => ss(() => months = 1)),
          _DurBtn("3 Meses", 3, months == 3, () => ss(() => months = 3)),
          _DurBtn("6 Meses", 6, months == 6, () => ss(() => months = 6)),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () async { Navigator.pop(c); await ResellerApi.extendClient(id, months: months); _load(); },
          child: const Text("RENOVAR", style: TextStyle(fontWeight: FontWeight.bold))),
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

class _DurBtn extends StatelessWidget {
  final String label;
  final int months;
  final bool selected;
  final VoidCallback onTap;
  const _DurBtn(this.label, this.months, this.selected, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AdminTheme.cyan.withOpacity(0.2) : AdminTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AdminTheme.cyan : Colors.transparent)),
      child: Text(label, style: TextStyle(color: selected ? AdminTheme.cyan : AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold))));
}
class _FilterChip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _FilterChip(this.label, this.value, this.selected, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onTap(value),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected == value ? const Color(0xFF6C3DE0).withOpacity(0.2) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected == value ? const Color(0xFF6C3DE0) : Colors.transparent)),
      child: Text(label, style: TextStyle(
        color: selected == value ? const Color(0xFF6C3DE0) : const Color(0xFF9E9E9E),
        fontSize: 12, fontWeight: FontWeight.w600))));
}
class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
    ]));
}
