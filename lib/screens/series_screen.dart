import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});
  @override State<SeriesScreen> createState() => _SeriesState();
}

class _SeriesState extends State<SeriesScreen> {
  List _series = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await AdminApi.getSeries();
    if (!mounted) return;
    setState(() { _series = r["series"] ?? []; _loading = false; });
  }

  String _getId(Map c) => (c["_id"] ?? c["id"] ?? "").toString().replaceAll("ObjectId(", "").replaceAll(")", "").replaceAll("'", "").trim();

  @override
  Widget build(BuildContext context) => _loading
    ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
    : RefreshIndicator(onRefresh: _load, color: AdminTheme.cyan,
        child: _series.isEmpty
          ? const Center(child: Text("No hay series", style: TextStyle(color: AdminTheme.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _series.length,
              itemBuilder: (ctx, i) {
                final s = _series[i];
                return Card(
                  color: AdminTheme.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.tv, color: AdminTheme.textHint),
                    title: Text(s["title"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: Text(s["category"] ?? "", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AdminTheme.red, size: 20),
                      onPressed: () async { await AdminApi.deleteSeries(_getId(s)); _load(); }),
                  ),
                );
              }));
}
