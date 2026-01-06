import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final String baseUrl = "https://movr.kolab.top/api/v1";

  void _logResponse(http.Response response, String action) {
    final method = response.request?.method ?? 'UNKNOWN';
    final url = response.request?.url.toString() ?? 'N/A';
    String body;
    try {
      final parsed = json.decode(response.body);
      body = const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (_) {
      body = response.body;
    }
    if (body.length > 1000) body = body.substring(0, 1000) + '...<truncated>';
    print('[ProfileService][$action] ${method} ${url} | status=${response.statusCode}');
    print('[ProfileService][$action] body:\n$body');
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    // PERBAIKAN: Gunakan 'access_token' sesuai dengan response dari AuthService/Laravel
    final token = prefs.getString('access_token'); 
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
    );
    _logResponse(response, 'getProfile');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // DEBUG: Membantu Anda melihat jika token ditolak (401) atau server error (500)
      debugPrint("Error Profile: ${response.statusCode} - ${response.body}");
      throw Exception('Gagal mengambil profil: ${response.statusCode}');
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/update'),
      headers: await _getHeaders(),
      body: json.encode({'name': name, 'email': email}),
    );
    _logResponse(response, 'updateProfile');
    return response.statusCode == 200;
  }

  Future<void> addAlamat(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/alamat'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    _logResponse(response, 'addAlamat');
    if (response.statusCode != 200) {
      throw Exception('Gagal menambah alamat');
    }
  }

  // --- TAMBAHKAN FUNGSI INI ---
  Future<void> destroyAlamat(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/profile/alamat/$id'),
      headers: await _getHeaders(),
    );
    _logResponse(response, 'destroyAlamat');

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus alamat');
    }
  }
}