import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final String baseUrl = kIsWeb 
      ? "http://127.0.0.1:8000/api/v1" 
      : "http://10.0.2.2:8000/api/v1";

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
    return response.statusCode == 200;
  }

  Future<void> addAlamat(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/alamat'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
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

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus alamat');
    }
  }
}