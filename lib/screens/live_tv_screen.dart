import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'player_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});
  @override State<LiveTvScreen> createState() => _State();
}

class _State extends State<LiveTvScreen> {
  List<Channel> _channels = [];
  bool _loading = true;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final channels = await ApiService.getChannels(search: _search.isEmpty ? null : _search);
      setState(() => _channels = channels);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Map<String, List<Channel>> get _grouped {
    final map = <String, List<Channel>>{};
    for (final ch in _channels) map.putIfAbsent(ch.category, () => []).add(ch);
    return map;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8),
        child: Row(children: [
          const Icon(Icons.all_inclusive, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          const Text('DemonTv Plus', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(width: 40, height: 40,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppTheme.logoGradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 22)),
        ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(controller: _searchCtrl, onChanged: (v) { _search = v; _load(); },
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
            hintText: '¿Qué canal buscás?',
            suffixIcon: _search.isNotEmpty ? IconButton(onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); _load(); }, icon: const Icon(Icons.close, color: AppTheme.textHint)) : null,
          ))),
      const SizedBox(height: 8),
      Expanded(child: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
        : ListView(padding: const EdgeInsets.only(bottom: 20),
            children: _grouped.entries.map((e) => _CategorySection(category: e.key, channels: e.value)).toList())),
    ])),
  );
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<Channel> channels;
  const _CategorySection({required this.category, required this.channels});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(16,16,16,10),
      child: Text(category, style: const TextStyle(color: AppTheme.accentCyan, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1))),
    SizedBox(height: 130, child: ListView.builder(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: channels.length,
      itemBuilder: (ctx, i) => _ChannelCard(channel: channels[i]))),
  ]);
}

class _ChannelCard extends StatelessWidget {
  final Channel channel;
  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel))),
    child: Container(width: 120, margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border, width: 0.5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 70, height: 70, child: ClipRRect(borderRadius: BorderRadius.circular(10),
          child: channel.logoUrl.isNotEmpty
            ? CachedNetworkImage(imageUrl: channel.logoUrl, fit: BoxFit.contain,
                placeholder: (_, __) => Container(color: AppTheme.surfaceAlt, child: const Icon(Icons.tv, color: AppTheme.textHint)),
                errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceAlt, child: const Icon(Icons.tv, color: AppTheme.textHint)))
            : Container(color: AppTheme.surfaceAlt, child: const Icon(Icons.tv, color: AppTheme.textHint)))),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(channel.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500))),
      ])),
  );
}
