import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class VersionScreen extends StatefulWidget {
  const VersionScreen({super.key});
  @override State<VersionScreen> createState() => _VersionState();
}

class _VersionState extends State<VersionScreen> {
  final _ver = TextEditingController();
  final _url = TextEditingController();
  final _log = TextEditingController();
  bool _force = false;
  bool _loading = false;
  String? _msg;
  bool _msgOk = true;

  @override void dispose() { _ver.dispose(); _url.dispose(); _log.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_msg != null) Container(
        width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _msgOk ? AdminTheme.green : AdminTheme.red, borderRadius: BorderRadius.circular(8)),
        child: Text(_msg!, style: const TextStyle(color: Colors.white))),
      const Text("Publicar Actualizacion", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      _f(_ver, "Version (ej: 1.2.0)"), const SizedBox(height: 12),
      _f(_url, "URL del APK"), const SizedBox(height: 12),
      _f(_log, "Changelog", lines: 3), const SizedBox(height: 12),
      Row(children: [
        Switch(value: _force, onChanged: (v) => setState(() => _force = v), activeColor: AdminTheme.cyan),
        const SizedBox(width: 8),
        const Text("Actualizacion forzada", style: TextStyle(color: Colors.white)),
      ]),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _loading ? null : () async {
            if (_ver.text.isEmpty || _url.text.isEmpty) { setState(() { _msg = "Version y URL requeridos"; _msgOk = false; }); return; }
            setState(() { _loading = true; _msg = null; });
            final r = await AdminApi.publishVersion(_ver.text.trim(), _url.text.trim(), _log.text.trim(), _force);
            if (!mounted) return;
            setState(() { _loading = false; _msg = r["success"] == true ? "Publicado!" : "Error: ${r["error"] ?? ""}"; _msgOk = r["success"] == true; });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text("Publicar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
    ]),
  );

  Widget _f(TextEditingController c, String h, {int lines = 1}) => TextField(
    controller: c, maxLines: lines, style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: h, hintStyle: const TextStyle(color: AdminTheme.textHint),
      filled: true, fillColor: AdminTheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
}
