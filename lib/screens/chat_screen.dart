import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../services/api.dart';
import '../theme/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatState();
}

class _ChatState extends State<ChatScreen> {
  io.Socket? _socket;
  final List<Map> _messages = [];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _connected = false;

  @override
  void initState() { super.initState(); _connect(); }

  void _connect() {
    _socket = io.io('http://149.104.92.205:25461', io.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
    _socket!.onConnect((_) {
      setState(() => _connected = true);
      _socket!.emit('auth', ResellerApi.token);
    });
    _socket!.on('pinned', (data) {
      if (data is Map) {
        setState(() => _messages.insert(0, {...data, 'pinned': true}));
      }
    });
    _socket!.on('history', (data) {
      if (data is List) { setState(() => _messages.addAll(data.cast<Map>())); _scrollBottom(); }
    });
    _socket!.on('message', (data) {
      if (data is Map) { setState(() => _messages.add(data)); _scrollBottom(); }
    });
    _socket!.onDisconnect((_) => setState(() => _connected = false));
    _socket!.connect();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _socket!.emit('message', text);
    _ctrl.clear();
  }

  @override
  void dispose() { _socket?.disconnect(); _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Color _roleColor(String role) {
    if (role == 'admin') return AdminTheme.cyan;
    if (role == 'reseller') return AdminTheme.gold;
    if (role == 'system') return AdminTheme.textSecondary;
    return Colors.white70;
  }

  String _formatTime(String iso) {
    try {
      final t = DateTime.parse(iso).toLocal();
      return "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AdminTheme.surfaceAlt,
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _connected ? AdminTheme.green : AdminTheme.red)),
        const SizedBox(width: 8),
        Text(_connected ? 'Chat grupal activo' : 'Conectando...', style: TextStyle(color: _connected ? AdminTheme.green : AdminTheme.red, fontSize: 12)),
      ])),
    Expanded(child: ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (ctx, i) {
        final m = _messages[i];
        final role = m['role'] ?? 'user';
        if (role == 'system') return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(m['text'] ?? '', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic))));
        return Padding(padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 14, backgroundColor: _roleColor(role).withOpacity(0.2),
              child: Text((m['user'] ?? '?')[0].toUpperCase(), style: TextStyle(color: _roleColor(role), fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(m['user'] ?? '', style: TextStyle(color: _roleColor(role), fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Text(_formatTime(m['time'] ?? ''), style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 10)),
              ]),
              const SizedBox(height: 2),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AdminTheme.surface, borderRadius: BorderRadius.circular(8)),
                child: Text(m['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13))),
            ])),
          ]));
      })),
    Container(padding: const EdgeInsets.fromLTRB(12,8,12,12), color: AdminTheme.surfaceAlt,
      child: Row(children: [
        Expanded(child: TextField(controller: _ctrl, style: const TextStyle(color: Colors.white, fontSize: 13),
          onSubmitted: (_) => _send(),
          decoration: InputDecoration(hintText: 'Escribir mensaje...', hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
        const SizedBox(width: 8),
        GestureDetector(onTap: _send,
          child: Container(width: 40, height: 40,
            decoration: const BoxDecoration(color: AdminTheme.cyan, shape: BoxShape.circle),
            child: const Icon(Icons.send, color: Colors.black, size: 18))),
      ])),
  ]);
}
