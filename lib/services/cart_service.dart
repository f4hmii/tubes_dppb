// --- BAGIAN INI WAJIB ADA (JANGAN DIHAPUS) ---
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
// ---------------------------------------------

class CartService {
  final String baseUrl = kIsWeb 
      ? "http://127.0.0.1:8000/api/v1" 
      : "http://10.0.2.2:8000/api/v1"; 

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Try both possible token keys to maintain compatibility
    final token = prefs.getString('access_token') ?? prefs.getString('token');
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login kembali.');
    }
    return token; 
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', 
    };
  }

  Future<Map<String, dynamic>> getCart() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/cart'), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Mengembalikan data keranjang
      return jsonResponse['data']; 
    } else {
      // Jika error, kita throw pesan agar UI tahu
      throw Exception('Gagal memuat keranjang: ${response.statusCode}');
    }
  }

  Future<void> addToCart(int produkId, int quantity) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
      body: json.encode({
        'produk_id': produkId, 
        'jumlah': quantity,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Gagal menambah produk');
    }
  }

  Future<void> updateCartItem(int cartItemId, int quantity) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: headers,
      body: json.encode({
        'jumlah': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update keranjang');
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus item');
    }
  }
}