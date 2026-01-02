import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class WishlistService {
  final String baseUrl = kIsWeb
      ? "http://127.0.0.1:8000/api/v1"
      : "http://10.0.0.2:8000/api/v1";

  // Get authentication token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Try both possible token keys to maintain compatibility
    final token = prefs.getString('access_token') ?? prefs.getString('token');
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      // If no token, return basic headers without auth (for fallback)
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all wishlist items
  Future<List<Map<String, dynamic>>> getWishlist() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat wishlist: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getting wishlist from API: $e");
      throw Exception('Gagal memuat wishlist: $e');
    }
  }

  // Add product to wishlist
  Future<Map<String, dynamic>> addToWishlist(int productId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: headers,
        body: json.encode({
          'product_id': productId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal menambahkan ke wishlist');
      }
    } catch (e) {
      print("Error adding to wishlist via API: $e");
      throw Exception('Gagal menambahkan ke wishlist: $e');
    }
  }

  // Remove product from wishlist by product ID
  Future<Map<String, dynamic>> removeFromWishlist(int productId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/product/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else if (response.statusCode == 404) {
        throw Exception('Produk tidak ditemukan di favorit');
      } else {
        throw Exception('Gagal menghapus dari wishlist');
      }
    } catch (e) {
      print("Error removing from wishlist via API: $e");
      throw Exception('Gagal menghapus dari wishlist: $e');
    }
  }

  // Remove favorite by ID
  Future<Map<String, dynamic>> removeFavoriteById(int favoriteId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$favoriteId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Gagal menghapus favorit');
      }
    } catch (e) {
      print("Error removing favorite via API: $e");
      throw Exception('Gagal menghapus favorit: $e');
    }
  }

  // Clear all favorites
  Future<Map<String, dynamic>> clearAllFavorites() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/clear'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Gagal menghapus semua favorit');
      }
    } catch (e) {
      print("Error clearing favorites via API: $e");
      throw Exception('Gagal menghapus semua favorit: $e');
    }
  }

  // Check if a product is in wishlist
  Future<bool> isInWishlist(int productId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/check/$productId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['is_favorited'] ?? false;
      }
      return false;
    } catch (e) {
      print("Error checking wishlist status via API: $e");
      throw Exception('Gagal mengecek status wishlist: $e');
    }
  }
}