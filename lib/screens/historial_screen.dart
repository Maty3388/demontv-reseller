import "package:flutter/material.dart";
import "../services/api.dart";
import "../theme/theme.dart";

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});
  @override State<HistorialScreen> createState() => _HistorialState();
}

class _HistorialState extends State<HistorialScreen> {
  List _transactions = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ResellerApi.getTransactions();
      setState(() => _transactions = r["transactions"] ?? r["logs"] ?? []);
    } catch (_) {}
    setState(() => _loading = false);
  }

  IconData _icon(String type) {
    if (type.contains("create")) return Icons.person_add;
    if (type.contains("extend") || type.contains("renew")) return Icons.calendar_month;
    if (type.contains("recharge")) return Icons.account_balance_wallet;
    return Icons.history;
  }

  Color _color(String type) {
    if (type.contains("create")) return const Color(0xFF4CAF50);
    if (type.contains("extend")) return const Color(0xFF00BCD4);
    if (type.contains("recharge")) return const Color(0xFFFFD700);
    return const Color(0xFF9E9E9E);
  }

  String _fmt(String iso) {
    try {
      final t = DateTime.parse(iso).toLocal();
      return "${t.day.toString().padLeft(2,"0")}/${t.month.toString().padLeft(2,"0")} ${t.hour.toString().padLeft(2,"0")}:${t.minute.toString().padLeft(2,"0")}";
    } catch (_) { return ""; }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0A0F),
    appBar: AppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      title: const Text("Historial", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF00E5FF)), onPressed: _load)],
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C3DE0)))
      : _transactions.isEmpty
        ? const Center(child: Text("Sin transacciones", style: TextStyle(color: Color(0xFF9E9E9E))))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _transactions.length,
            itemBuilder: (ctx, i) {
              final t = _transactions[i];
              final type = (t["type"] ?? "").toString();
              final color = _color(type);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2))),
                child: Row(children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(_icon(type), color: color, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t["description"] ?? type, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (t["email"] != null) Text(t["email"], style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)),
                  ])),
                  Text(_fmt(t["timestamp"] ?? t["createdAt"] ?? ""), style: const TextStyle(color: Color(0xFF5C5C5C), fontSize: 10)),
                ]));
            }));
}
