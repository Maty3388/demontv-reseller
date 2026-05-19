import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});
  @override State<LogsScreen> createState() => _LogsState();
}

class _LogsState extends State<LogsScreen> {
  List _logs = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await AdminApi.getLogs();
    if (!mounted) return;
    setState(() { _logs = r["logs"] ?? []; _loading = false; });
  }

  @override
  Widget build(BuildContext context) => _loading
    ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
    : RefreshIndicator(onRefresh: _load, color: AdminTheme.cyan,
        child: _logs.isEmpty
          ? const Center(child: Text("No hay logs", style: TextStyle(color: AdminTheme.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _logs.length,
              itemBuilder: (ctx, i) {
                final l = _logs[i];
                return Card(
                  color: AdminTheme.surface,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: AdminTheme.cyan, size: 18),
                    title: Text(l["action"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    subtitle: Text(l["createdAt"] ?? "", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 10)),
                    dense: true));
              }));
}
