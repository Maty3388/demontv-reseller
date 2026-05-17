import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://149.104.92.205';
  static String? _token;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;
  static bool get isLoggedIn => _token != null;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) _token = data['token'];
    return data;
  }

  static Future<List<Channel>> getChannels({String? search, String? category}) async {
    var url = '$baseUrl/channels';
    final p = <String>[];
    if (search != null) p.add('search=${Uri.encodeComponent(search)}');
    if (category != null) p.add('category=${Uri.encodeComponent(category)}');
    if (p.isNotEmpty) url += '?${p.join('&')}';
    final res = await http.get(Uri.parse(url), headers: _headers);
    final data = jsonDecode(res.body);
    return (data['channels'] as List).map((c) => _channelFromJson(c)).toList();
  }

  static Future<List<Content>> getMovies({bool featuredOnly = false, String? search}) async {
    var url = '$baseUrl/movies';
    final p = <String>[];
    if (featuredOnly) p.add('featured=true');
    if (search != null) p.add('search=${Uri.encodeComponent(search)}');
    if (p.isNotEmpty) url += '?${p.join('&')}';
    final res = await http.get(Uri.parse(url), headers: _headers);
    final data = jsonDecode(res.body);
    return (data['movies'] as List).map((m) => _movieFromJson(m)).toList();
  }

  static Future<List<Content>> getSeries({bool featuredOnly = false, String? search}) async {
    var url = '$baseUrl/series';
    final p = <String>[];
    if (featuredOnly) p.add('featured=true');
    if (search != null) p.add('search=${Uri.encodeComponent(search)}');
    if (p.isNotEmpty) url += '?${p.join('&')}';
    final res = await http.get(Uri.parse(url), headers: _headers);
    final data = jsonDecode(res.body);
    return (data['series'] as List).map((s) => _seriesFromJson(s)).toList();
  }

  static Channel _channelFromJson(Map<String, dynamic> j) {
    final rawUrl = j['stream_url'] as String? ?? '';
    final parts = rawUrl.split('|');
    final url = parts[0].trim();
    final headers = <String, String>{};
    if (parts.length > 1) {
      for (final kv in parts[1].split('&')) {
        final idx = kv.indexOf('=');
        if (idx > 0) headers[kv.substring(0, idx).trim()] = kv.substring(idx + 1).trim();
      }
    }
    return Channel(id: j['id'], name: j['name'], category: j['category'], logoUrl: j['logo'] ?? '', streamUrl: url, headers: headers, isLive: j['is_live'] ?? true, epgNow: j['epg_now'], epgNext: j['epg_next'], number: j['number']);
  }

  static Content _movieFromJson(Map<String, dynamic> j) => Content(
    id: j['id'], title: j['title'], posterUrl: j['poster'] ?? '',
    type: ContentType.movie, year: j['year']?.toString(), rating: j['rating']?.toString(),
    description: j['description'], streamUrl: j['stream_url']?.isEmpty == true ? null : j['stream_url'],
  );

  static Content _seriesFromJson(Map<String, dynamic> j) {
    final episodes = <Episode>[];
    for (final season in (j['seasons'] as List? ?? [])) {
      for (final ep in (season['episodes'] as List? ?? [])) {
        episodes.add(Episode(id: ep['id'], title: ep['title'], season: season['season'], episode: ep['episode'], streamUrl: ep['stream_url'] ?? '', thumbnailUrl: ep['thumbnail']));
      }
    }
    return Content(id: j['id'], title: j['title'], posterUrl: j['poster'] ?? '', type: ContentType.series, year: j['year']?.toString(), rating: j['rating']?.toString(), description: j['description'], episodes: episodes);
  }
}
