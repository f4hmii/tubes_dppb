import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';

class WishlistService {
  final String baseUrl = kIsWeb
      ? "http://127.0.0.1:8000/api/v1"
      : "http://10.0.0.2:8000/api/v1";

  // Get authentication token (optional - for API calls)
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

  // Get locally stored favorite product IDs
  Future<List<int>> _getLocalFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites') ?? '[]';
    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.cast<int>();
  }

  // Save favorite product IDs locally
  Future<void> _saveLocalFavorites(List<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', json.encode(favoriteIds));
  }

  // Check if product is in local favorites
  Future<bool> _isInLocalFavorites(int productId) async {
    final favorites = await _getLocalFavorites();
    return favorites.contains(productId);
  }

  // Add to local favorites
  Future<void> _addToLocalFavorites(int productId) async {
    final favorites = await _getLocalFavorites();
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await _saveLocalFavorites(favorites);
    }
  }

  // Remove from local favorites
  Future<void> _removeFromLocalFavorites(int productId) async {
    final favorites = await _getLocalFavorites();
    favorites.remove(productId);
    await _saveLocalFavorites(favorites);
  }

  // Get all wishlist items
  Future<List<Product>> getWishlist() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/favorite'), // Try 'favorite' endpoint as alternative
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        // If 'favorite' endpoint doesn't work, try 'favorites'
        final response2 = await http.get(
          Uri.parse('$baseUrl/favorites'),
          headers: headers,
        );

        if (response2.statusCode == 200) {
          final jsonResponse = json.decode(response2.body);
          final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;
          return data.map((item) => Product.fromJson(item)).toList();
        } else {
          throw Exception('Gagal memuat wishlist: ${response2.statusCode}');
        }
      }
    } catch (e) {
      print("Error getting wishlist from API: $e");
      // Fallback to local storage
      print("Falling back to local storage for wishlist...");
      // For now, return empty list since we can't fetch actual product details without API
      // The wishlist page will handle getting products by IDs separately
      return [];
    }
  }

  // Add product to wishlist
  Future<void> addToWishlist(int productId) async {
    try {
      final headers = await _getHeaders();
      // Try 'favorite' endpoint first as alternative to 'wishlist'
      final response = await http.post(
        Uri.parse('$baseUrl/favorite'),
        headers: headers,
        body: json.encode({
          'produk_id': productId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // If 'favorite' doesn't work, try 'favorites'
        final response2 = await http.post(
          Uri.parse('$baseUrl/favorites'),
          headers: headers,
          body: json.encode({
            'produk_id': productId,
          }),
        );

        if (response2.statusCode != 200 && response2.statusCode != 201) {
          final error = json.decode(response2.body);
          throw Exception(error['message'] ?? 'Gagal menambahkan ke wishlist');
        }
      }
    } catch (e) {
      print("Error adding to wishlist via API: $e");
      print("Falling back to local storage for adding to wishlist...");
      // Fallback to local storage
      await _addToLocalFavorites(productId);
    }
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(int productId) async {
    try {
      final headers = await _getHeaders();
      // Try 'favorite' endpoint first as alternative to 'wishlist'
      final response = await http.delete(
        Uri.parse('$baseUrl/favorite/$productId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        // If 'favorite' doesn't work, try 'favorites'
        final response2 = await http.delete(
          Uri.parse('$baseUrl/favorites/$productId'),
          headers: headers,
        );

        if (response2.statusCode != 200) {
          throw Exception('Gagal menghapus dari wishlist');
        }
      }
    } catch (e) {
      print("Error removing from wishlist via API: $e");
      print("Falling back to local storage for removing from wishlist...");
      // Fallback to local storage
      await _removeFromLocalFavorites(productId);
    }
  }

  // Check if a product is in wishlist
  Future<bool> isInWishlist(int productId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/favorite/check/$productId'), // Try 'favorite' as alternative
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['is_in_wishlist'] ?? false;
      }
      return false;
    } catch (e) {
      print("Error checking wishlist status via API: $e");
      print("Falling back to local storage for checking wishlist status...");
      // Fallback to local storage
      return await _isInLocalFavorites(productId);
    }
  }
}