import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "../services/api.dart";
import "../theme/theme.dart";

class SubResellersScreen extends StatefulWidget {
  const SubResellersScreen({super.key});
  @override State<SubResellersScreen> createState() => _SubResellersState();
}

class _SubResellersState extends State<SubResellersScreen> {
  List _resellers = [];
  bool _loading = true;
  Map _profile = {};

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ResellerApi.getSubResellers();
    final p = await ResellerApi.getProfile();
    if (!mounted) return;
    setState(() { _resellers = r["resellers"] ?? []; _profile = p; _loading = false; });
  }

  String _rankEmoji(String rank) {
    switch(rank) {
      case "Plata": return "🥈";
      case "Oro": return "🥇";
      case "Diamante": return "💎";
      default: return "🥉";
    }
  }

  @override
  Widget build(BuildContext context) => _loading
    ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
    : Column(children: [
        Padding(padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Text("Mis Revendedores", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Nuevo", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C3DE0), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _showAddDialog(context)),
          ])),
        Expanded(child: _resellers.isEmpty
          ? const Center(child: Text("No tenés revendedores", style: TextStyle(color: AdminTheme.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _resellers.length,
              itemBuilder: (ctx, i) {
                final r = _resellers[i];
                final rank = r["rank"] ?? "Bronce";
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminTheme.cyan.withOpacity(0.2))),
                  child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                    Text(_rankEmoji(rank), style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r["name"] ?? r["email"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(r["email"] ?? "", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text("$rank · ${r["balance"] ?? 0} coins", style: const TextStyle(color: AdminTheme.cyan, fontSize: 11)),
                    ])),
                  ])));
              })),
      ]);

  void _showAddDialog(BuildContext ctx) {
    final email = TextEditingController();
    final pass  = TextEditingController();
    final name  = TextEditingController();
    final rank = _profile["rank"] ?? "Bronce";
    final allowed = {"Plata": ["Bronce"], "Oro": ["Bronce","Plata"], "Diamante": ["Bronce","Plata","Oro","Diamante"]};
    final allowedRanks = allowed[rank] ?? [];
    String selectedRank = allowedRanks.isNotEmpty ? allowedRanks[0] : "Bronce";
    int balance = 0;

    showDialog(context: ctx, builder: (c) => StatefulBuilder(builder: (c, ss) => AlertDialog(
      backgroundColor: AdminTheme.surface,
      title: const Text("Nuevo Revendedor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: _field(name, "Nombre")),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _field(email, "Email")),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C3DE0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              final rand = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
              ss(() { email.text = "res$rand@demon.tv"; pass.text = "pass$rand"; });
            },
            child: const Text("🎲", style: TextStyle(fontSize: 16))),
        ]),
        const SizedBox(height: 8),
        _field(pass, "Contraseña", obscure: true),
        const SizedBox(height: 12),
        if (allowedRanks.isNotEmpty) ...[
          const Align(alignment: Alignment.centerLeft, child: Text("Rango:", style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12))),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: allowedRanks.map((r) => GestureDetector(
            onTap: () => ss(() => selectedRank = r),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selectedRank == r ? AdminTheme.cyan.withOpacity(0.2) : AdminTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selectedRank == r ? AdminTheme.cyan : Colors.transparent)),
              child: Text(r, style: TextStyle(color: selectedRank == r ? AdminTheme.cyan : AdminTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)))
          )).toList()),
          const SizedBox(height: 12),
        ],
        const Align(alignment: Alignment.centerLeft, child: Text("Coins iniciales:", style: TextStyle(color: AdminTheme.textSecondary, fontSize: 12))),
        const SizedBox(height: 6),
        TextField(
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
          onChanged: (v) => ss(() => balance = int.tryParse(v) ?? 0),
          decoration: InputDecoration(
            hintText: "0", hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surfaceAlt,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 10))),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black),
          onPressed: () async {
            if (email.text.isNotEmpty && pass.text.isNotEmpty) {
              Navigator.pop(c);
              final r = await ResellerApi.createSubReseller(email.text.trim(), pass.text.trim(), name.text.trim(), selectedRank, balance);
              if (r["success"] == true) {
                final text = "😈DemonPanel😈\n😈Vendedor Creado😈\n\nEmail: ${email.text.trim()}\nContraseña: ${pass.text.trim()}\nRango: $selectedRank";
                await Clipboard.setData(ClipboardData(text: text));
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("✅ Credenciales copiadas"), backgroundColor: AdminTheme.green));
                _load();
              } else if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(r["error"] ?? "Error"), backgroundColor: AdminTheme.red));
              }
            }
          }, child: const Text("CREAR")),
      ])));
  }

  Widget _field(TextEditingController ctrl, String hint, {bool obscure = false}) =>
    TextField(controller: ctrl, obscureText: obscure, style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AdminTheme.textSecondary),
        filled: true, fillColor: AdminTheme.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)));
}
