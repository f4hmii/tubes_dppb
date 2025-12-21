import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  final String baseUrl = "https://fakestoreapi.com";

  // 1. GET: Ambil Semua Produk
  Future<List<dynamic>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat produk');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // 2. GET: Ambil Detail Produk
  Future<Map<String, dynamic>> getProductDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail produk');
    }
  }

  // 3. GET: Ambil Semua Kategori
  Future<List<dynamic>> getAllCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/products/categories'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  // 4. GET: Ambil Produk berdasarkan Kategori
  Future<List<dynamic>> getProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/products/category/$category'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat produk kategori');
    }
  }

 // 5. POST: Login User (VERSI ROBUST / KEBAL ERROR)
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('Debug Status Code: ${response.statusCode}'); // Cek di console
      print('Debug Response: ${response.body}');          // Cek di console

      // 1. Decode data dulu
      final Map<String, dynamic> responseData = json.decode(response.body);

      // 2. Syarat Sukses Baru: CEK APAKAH ADA TOKEN?
      // Jika ada key 'token', kita anggap sukses, berapapun status codenya.
      if (responseData.containsKey('token')) {
        return responseData;
      } else {
        throw Exception('Gagal: Token tidak ditemukan dalam respon');
      }
    } catch (e) {
      // Tangkap error koneksi atau error parsing
      print("Error pada fungsi login: $e");
      rethrow; // Lempar error ke UI agar muncul SnackBar merah
    }
  }

  // 6. POST: Register User
  Future<Map<String, dynamic>> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      body: {
        'email': email,
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Register gagal');
    }
  }

  // 7. GET: Ambil Data User/Profile
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat profil');
    }
  }

  // 8. PUT: Update User
  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal update profil');
    }
  }

  // 9. DELETE: Hapus Cart
  Future<Map<String, dynamic>> deleteCart(int cartId) async {
    final response = await http.delete(Uri.parse('$baseUrl/carts/$cartId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal menghapus keranjang');
    }
  }
// 11. GET: Ambil Keranjang User (Hanya mengembalikan ID Produk)
  Future<List<dynamic>> getUserCart(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/carts/user/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat keranjang');
    }
  }
  // 10. POST: Checkout (Simulasi)
  // Perhatikan posisinya: Ada DI DALAM kurung kurawal penutup class
  Future<Map<String, dynamic>> checkout(int userId, List<Map<String, dynamic>> products) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'date': DateTime.now().toIso8601String(),
          'products': products, 
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal membuat pesanan');
      }
    } catch (e) {
      throw Exception('Error checkout: $e');
    }
  }

} // <--- KURUNG TUTUP CLASS ADA DI SINI (JANGAN DIHAPUS)