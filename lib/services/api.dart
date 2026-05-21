import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApi {
  static const base = 'http://149.104.92.205:25461';
  static String? token;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('admin_token');
  }

  static Future<void> saveToken(String t) async {
    token = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', t);
  }

  static Future<void> clearToken() async {
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
  }

  static Future<Map<String, dynamic>> _post(String path, Map body) async {
    try {
      final r = await http.post(Uri.parse('$base$path'), headers: headers, body: jsonEncode(body));
      return jsonDecode(r.body);
    } catch(e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final r = await http.get(Uri.parse('$base$path'), headers: headers);
      return jsonDecode(r.body);
    } catch(e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> _put(String path, Map body) async {
    try {
      final r = await http.put(Uri.parse('$base$path'), headers: headers, body: jsonEncode(body));
      return jsonDecode(r.body);
    } catch(e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    try {
      final r = await http.delete(Uri.parse('$base$path'), headers: headers);
      return jsonDecode(r.body);
    } catch(e) { return {'error': e.toString()}; }
  }

  static Future<Map<String, dynamic>> login(String email, String pass) async {
    final r = await _post('/admin/login', {'email': email, 'password': pass});
    if (r['token'] != null) await saveToken(r['token']);
    return r;
  }

  static Future<Map<String, dynamic>> getStats()    => _get('/admin/stats');
  static Future<Map<String, dynamic>> getChannels() => _get('/admin/channels');
  static Future<Map<String, dynamic>> getClients()  => _get('/admin/clients');
  static Future<Map<String, dynamic>> getMovies()   => _get('/admin/movies');
  static Future<Map<String, dynamic>> getSeries()   => _get('/admin/series');
  static Future<Map<String, dynamic>> getLogs()     => _get('/admin/logs');

  static Future<Map<String, dynamic>> addChannel(String name, String category, String logo, String url) =>
    _post('/admin/channels', {'name': name, 'category': category, 'logo': logo, 'stream_url': url});

  static Future<Map<String, dynamic>> updateChannel(String id, String name, String category, String logo, String url) =>
    _put('/admin/channels/$id', {'name': name, 'category': category, 'logo': logo, 'stream_url': url});

  static Future<Map<String, dynamic>> deleteChannel(String id) => _delete('/admin/channels/$id');

  static Future<Map<String, dynamic>> addClient(String email, String pass, String expiry) =>
    _post('/admin/clients', {'email': email, 'password': pass, 'subscription_end': expiry});

  static Future<Map<String, dynamic>> updateClient(String id, {bool? blocked, String? password, String? expiry}) =>
    _put('/admin/clients/$id', {if (blocked != null) 'blocked': blocked, if (password != null) 'password': password, if (expiry != null) 'subscription_end': expiry});

  static Future<Map<String, dynamic>> deleteClient(String id) => _delete('/admin/clients/$id');
  static Future<Map<String, dynamic>> removeDevice(String id) => _delete('/admin/clients/$id/device');

  static Future<Map<String, dynamic>> addMovie(String title, String category, String poster, String url) =>
    _post('/admin/movies', {'title': title, 'category': category, 'poster': poster, 'stream_url': url});

  static Future<Map<String, dynamic>> deleteMovie(String id) => _delete('/admin/movies/$id');

  static Future<Map<String, dynamic>> addSeries(String title, String category, String poster) =>
    _post('/admin/series', {'title': title, 'category': category, 'poster': poster});

  static Future<Map<String, dynamic>> deleteSeries(String id) => _delete('/admin/series/$id');

  static Future<Map<String, dynamic>> fetchM3u(String url) =>
    _post('/admin/fetch-m3u', {'url': url});

  static Future<Map<String, dynamic>> parseM3u(String content) =>
    _post('/admin/parse-m3u', {'content': content});

  static Future<Map<String, dynamic>> publishVersion(String version, String apkUrl, String changelog, bool force) =>
    _put('/admin/app/version', {'version': version, 'apkUrl': apkUrl, 'changelog': changelog, 'forceUpdate': force});
}
