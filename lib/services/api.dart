import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResellerApi {
  static const String _base = 'http://149.104.92.205:25461';
  static String? _token;

  static String? get token => _token;
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<void> loadToken() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('reseller_token');
  }

  static Future<void> clearToken() async {
    _token = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('reseller_token');
  }

  static bool get isLoggedIn => _token != null;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await http.post(Uri.parse('$_base/reseller/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}));
    final data = jsonDecode(r.body);
    if (r.statusCode == 200 && data['token'] != null) {
      _token = data['token'];
      final p = await SharedPreferences.getInstance();
      await p.setString('reseller_token', _token!);
    }
    return data;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final r = await http.get(Uri.parse('$_base/reseller/profile'), headers: _headers);
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> getClients() async {
    final r = await http.get(Uri.parse('$_base/reseller/clients'), headers: _headers);
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> createClient(String email, String password, int months) async {
    final r = await http.post(Uri.parse('$_base/reseller/clients'),
      headers: _headers, body: jsonEncode({'email': email, 'password': password, 'months': months}));
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> extendClient(String id, {int months = 1}) async {
    final r = await http.post(Uri.parse('$_base/reseller/clients/$id/extend'),
      headers: _headers, body: jsonEncode({'months': months}));
    return jsonDecode(r.body);
  }
  static Future<Map<String, dynamic>> getSubResellers() async { final r = await http.get(Uri.parse("$_base/reseller/sub-resellers"), headers: _headers); return jsonDecode(r.body); }
  static Future<Map<String, dynamic>> createSubReseller(String email, String pass, String name, String rank, int balance) async { final r = await http.post(Uri.parse("$_base/reseller/create-reseller"), headers: _headers, body: jsonEncode({"email": email, "password": pass, "name": name, "rank": rank, "balance": balance})); return jsonDecode(r.body); }

  static Future<Map<String, dynamic>> updateClient(String id, {String? email, String? password}) async {
    final body = <String, dynamic>{};
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    final r = await http.patch(Uri.parse('$_base/reseller/clients/$id'), headers: _headers, body: jsonEncode(body));
    return jsonDecode(r.body);
  }

  static Future<void> removeDevice(String id) async {
    await http.delete(Uri.parse('$_base/reseller/clients/$id/device'), headers: _headers);
  }

}
