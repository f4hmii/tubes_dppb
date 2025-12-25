import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_model.dart'; // PAKAI INI
import '../models/category_model.dart' as cat;
import 'package:flutter/foundation.dart';
class ProductService {
 final String baseUrl = kIsWeb 
      ? "http://127.0.0.1:8000/api/v1"   // <--- Perhatikan ada /v1
      : "http://10.0.2.2:8000/api/v1";   // <--- Perhatikan ada /v1
  // --- Helper Function (Biar tidak koding berulang-ulang) ---
  List<Product> _parseProductList(dynamic jsonResponse) {
    List<dynamic> data;
    // Cek apakah dibungkus 'data' (API Resource Laravel)
    if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
      data = jsonResponse['data'];
    } else if (jsonResponse is List) {
      data = jsonResponse;
    } else {
      return [];
    }
    return data.map((item) => Product.fromJson(item)).toList();
  }
  // -----------------------------------------------------------

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        // Pakai helper function biar rapi
        return _parseProductList(jsonResponse);
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode}');
      }
    } catch (e) {
      print("Error Service getAllProducts: $e");
      throw Exception('Error koneksi: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$categoryId'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
         final dynamic jsonResponse = json.decode(response.body);
         // Pakai helper function yang SAMA, jadi aman kalau format JSON berubah
         return _parseProductList(jsonResponse);
      } else {
        throw Exception('Gagal memuat produk kategori: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error kategori: $e');
    }
  }

  // GET: Ambil Semua Kategori dari API Lokal
  Future<List<cat.ProductCategory>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        List<dynamic> categories = [];
        
        // Handle jika API mengembalikan wrapper 'data'
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
          categories = jsonResponse['data'];
        } else if (jsonResponse is List) {
          categories = jsonResponse;
        } else {
          throw Exception('Format response tidak sesuai');
        }
        
        // Parse ke ProductCategory model
        return categories.map((catItem) => cat.ProductCategory.fromJson(catItem as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat kategori: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getAllCategories: $e');
      throw Exception('Error kategori: $e');
    }
  }
}