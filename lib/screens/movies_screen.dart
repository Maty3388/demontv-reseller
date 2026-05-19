import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});
  @override State<MoviesScreen> createState() => _MoviesState();
}

class _MoviesState extends State<MoviesScreen> {
  List _movies = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await AdminApi.getMovies();
    if (!mounted) return;
    setState(() { _movies = r["movies"] ?? []; _loading = false; });
  }

  String _getId(Map c) => (c["_id"] ?? c["id"] ?? "").toString().replaceAll("ObjectId(", "").replaceAll(")", "").replaceAll("'", "").trim();

  @override
  Widget build(BuildContext context) => _loading
    ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
    : RefreshIndicator(onRefresh: _load, color: AdminTheme.cyan,
        child: _movies.isEmpty
          ? const Center(child: Text("No hay peliculas", style: TextStyle(color: AdminTheme.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _movies.length,
              itemBuilder: (ctx, i) {
                final m = _movies[i];
                final id = _getId(m);
                return Card(
                  color: AdminTheme.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.movie, color: AdminTheme.textHint),
                    title: Text(m["title"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: Text(m["category"] ?? "", style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AdminTheme.red, size: 20),
                      onPressed: () async { await AdminApi.deleteMovie(id); _load(); }),
                  ),
                );
              }));
}
