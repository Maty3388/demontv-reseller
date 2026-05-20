import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});
  @override State<ChannelsScreen> createState() => _ChannelsState();
}

class _ChannelsState extends State<ChannelsScreen> {
  List _channels = [];
  bool _loading = true;
  String? _msg;
  bool _msgOk = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await AdminApi.getChannels();
    if (!mounted) return;
    setState(() { _channels = r['channels'] ?? []; _loading = false; });
  }

  Future<void> _delete(String id) async {
    final r = await AdminApi.deleteChannel(id);
    if (!mounted) return;
    if (r['success'] == true) {
      setState(() {
        _channels.removeWhere((c) => (c['_id'] ?? c['id'] ?? '').toString().contains(id));
        _msg = 'Canal eliminado';
        _msgOk = true;
      });
    } else {
      setState(() { _msg = 'Error: ${r["error"] ?? r.toString()}'; _msgOk = false; });
    }
  }

  String _getId(Map c) => (c['_id'] ?? c['id'] ?? '').toString().replaceAll('ObjectId(', '').replaceAll(')', '').replaceAll("'", '').trim();

  @override
  Widget build(BuildContext context) => Column(children: [
    // Botones de accion
    Container(
      color: AdminTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Expanded(child: ElevatedButton.icon(
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Agregar Canal'),
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.cyan, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 10)),
          onPressed: () => showDialog(context: context, builder: (_) => _AddDialog(onAdded: (msg) { _load(); setState(() { _msg = msg; _msgOk = true; }); })))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file, size: 16),
          label: const Text('Importar M3U'),
          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 10)),
          onPressed: () => showDialog(context: context, builder: (_) => _ImportM3uDialog(onImported: (msg) { _load(); setState(() { _msg = msg; _msgOk = true; }); })))),
      ])),
    if (_msg != null) MaterialBanner(
      content: Text(_msg!, style: const TextStyle(color: Colors.white)),
      backgroundColor: _msgOk ? AdminTheme.green : AdminTheme.red,
      actions: [TextButton(onPressed: () => setState(() => _msg = null), child: const Text('OK', style: TextStyle(color: Colors.white)))]),
    Expanded(child: _loading
      ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
      : RefreshIndicator(onRefresh: _load, color: AdminTheme.cyan,
          child: _channels.isEmpty
            ? const Center(child: Text('No hay canales', style: TextStyle(color: AdminTheme.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _channels.length,
                itemBuilder: (ctx, i) {
                  final c = _channels[i];
                  final id = _getId(c);
                  return Card(
                    color: AdminTheme.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: AdminTheme.surfaceAlt, borderRadius: BorderRadius.circular(8)),
                        child: c['logo']?.isNotEmpty == true
                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(c['logo'], fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.tv, color: AdminTheme.textHint)))
                          : const Icon(Icons.tv, color: AdminTheme.textHint)),
                      title: Text(c['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(c['category'] ?? '', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: AdminTheme.cyan, size: 20),
                          onPressed: () => showDialog(context: context, builder: (_) => _EditDialog(id: id, channel: c, onSaved: (msg) { _load(); setState(() { _msg = msg; _msgOk = true; }); }))),
                        IconButton(icon: const Icon(Icons.delete_outline, color: AdminTheme.red, size: 20),
                          onPressed: () => _delete(id)),
                      ]),
                    ),
                  );
                }))),
  ]);
}

class _EditDialog extends StatefulWidget {
  final String id;
  final Map channel;
  final Function(String) onSaved;
  const _EditDialog({required this.id, required this.channel, required this.onSaved});
  @override State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final _name = TextEditingController(text: widget.channel['name'] ?? '');
  late final _cat  = TextEditingController(text: widget.channel['category'] ?? '');
  late final _logo = TextEditingController(text: widget.channel['logo'] ?? '');
  late final _url  = TextEditingController(text: widget.channel['stream_url'] ?? '');
  bool _loading = false;
  String? _error;

  @override void dispose() { _name.dispose(); _cat.dispose(); _logo.dispose(); _url.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AdminTheme.surface,
    title: const Text('Editar Canal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      _f(_name, 'Nombre *'), _f(_cat, 'Categoria'), _f(_logo, 'URL Logo'), _f(_url, 'URL Stream *'),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: AdminTheme.red, fontSize: 12))),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: AdminTheme.textSecondary))),
      TextButton(onPressed: _loading ? null : () async {
        if (_name.text.isEmpty || _url.text.isEmpty) { setState(() => _error = 'Nombre y URL requeridos'); return; }
        setState(() { _loading = true; _error = null; });
        final r = await AdminApi.updateChannel(widget.id, _name.text.trim(), _cat.text.trim().isNotEmpty ? _cat.text.trim() : 'General', _logo.text.trim(), _url.text.trim());
        if (!mounted) return;
        setState(() => _loading = false);
        if (r['success'] == true) { widget.onSaved('Canal actualizado'); Navigator.pop(context); }
        else setState(() => _error = r['error'] ?? 'Error');
      }, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AdminTheme.cyan)) : const Text('GUARDAR', style: TextStyle(color: AdminTheme.cyan, fontWeight: FontWeight.bold))),
    ],
  );

  Widget _f(TextEditingController c, String h) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: TextField(controller: c, style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(hintText: h, filled: true, fillColor: AdminTheme.surfaceAlt, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))));
}

class _AddDialog extends StatefulWidget {
  final Function(String) onAdded;
  const _AddDialog({required this.onAdded});
  @override State<_AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<_AddDialog> {
  final _name = TextEditingController();
  final _cat  = TextEditingController();
  final _logo = TextEditingController();
  final _url  = TextEditingController();
  bool _loading = false;
  String? _error;

  @override void dispose() { _name.dispose(); _cat.dispose(); _logo.dispose(); _url.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AdminTheme.surface,
    title: const Text("Agregar Canal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      _f(_name, "Nombre *"), _f(_cat, "Categoria"), _f(_logo, "URL Logo"), _f(_url, "URL Stream *"),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: AdminTheme.red, fontSize: 12))),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
      TextButton(onPressed: _loading ? null : () async {
        if (_name.text.isEmpty || _url.text.isEmpty) { setState(() => _error = "Nombre y URL requeridos"); return; }
        setState(() { _loading = true; _error = null; });
        final r = await AdminApi.addChannel(_name.text.trim(), _cat.text.trim().isNotEmpty ? _cat.text.trim() : "General", _logo.text.trim(), _url.text.trim());
        if (!mounted) return;
        setState(() => _loading = false);
        if (r["success"] == true) { widget.onAdded("Canal agregado"); Navigator.pop(context); }
        else setState(() => _error = r["error"] ?? "Error");
      }, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AdminTheme.cyan)) : const Text("AGREGAR", style: TextStyle(color: AdminTheme.cyan, fontWeight: FontWeight.bold))),
    ],
  );

  Widget _f(TextEditingController c, String h) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: TextField(controller: c, style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(hintText: h, filled: true, fillColor: AdminTheme.surfaceAlt, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))));
}

class _ImportM3uDialog extends StatefulWidget {
  final Function(String) onImported;
  const _ImportM3uDialog({required this.onImported});
  @override State<_ImportM3uDialog> createState() => _ImportM3uDialogState();
}

class _ImportM3uDialogState extends State<_ImportM3uDialog> {
  final _url = TextEditingController();
  final _paste = TextEditingController();
  bool _loading = false;
  String? _error;
  int _tab = 0;

  @override void dispose() { _url.dispose(); _paste.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AdminTheme.surface,
    title: const Text("Importar M3U", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Expanded(child: GestureDetector(onTap: () => setState(() => _tab = 0), child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: _tab == 0 ? AdminTheme.cyan.withOpacity(0.2) : Colors.transparent, border: Border(bottom: BorderSide(color: _tab == 0 ? AdminTheme.cyan : Colors.transparent, width: 2))), child: Text("URL", textAlign: TextAlign.center, style: TextStyle(color: _tab == 0 ? AdminTheme.cyan : AdminTheme.textSecondary, fontWeight: FontWeight.bold))))),
        Expanded(child: GestureDetector(onTap: () => setState(() => _tab = 1), child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: _tab == 1 ? AdminTheme.cyan.withOpacity(0.2) : Colors.transparent, border: Border(bottom: BorderSide(color: _tab == 1 ? AdminTheme.cyan : Colors.transparent, width: 2))), child: Text("Pegar", textAlign: TextAlign.center, style: TextStyle(color: _tab == 1 ? AdminTheme.cyan : AdminTheme.textSecondary, fontWeight: FontWeight.bold))))),
      ]),
      const SizedBox(height: 12),
      if (_tab == 0) TextField(controller: _url, style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(hintText: "https://...", filled: true, fillColor: AdminTheme.surfaceAlt, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)))
      else TextField(controller: _paste, maxLines: 5, style: const TextStyle(color: Colors.white, fontSize: 11),
        decoration: InputDecoration(hintText: "#EXTM3U...", filled: true, fillColor: AdminTheme.surfaceAlt, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),

      if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: AdminTheme.red, fontSize: 12))),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: AdminTheme.textSecondary))),
      TextButton(onPressed: _loading ? null : () async {
        final content = _tab == 0 ? _url.text.trim() : _paste.text.trim();
        if (content.isEmpty) { setState(() => _error = "Ingresa URL o contenido M3U"); return; }
        setState(() { _loading = true; _error = null; });
        final r = _tab == 0
          ? await AdminApi.fetchM3u(content)
          : await AdminApi.parseM3u(content);
        if (!mounted) return;
        setState(() => _loading = false);
        if (r["success"] == true) { widget.onImported("${r["imported"] ?? 0} canales importados"); Navigator.pop(context); }
        else setState(() => _error = r["error"] ?? "Error al importar");
      }, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AdminTheme.cyan)) : const Text("IMPORTAR", style: TextStyle(color: AdminTheme.cyan, fontWeight: FontWeight.bold))),
    ],
  );
}
