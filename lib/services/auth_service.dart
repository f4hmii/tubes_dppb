import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // -----------------------------------------------------------
  // PENTING: Ganti URL sesuai device yang Anda pakai testing!
  // -----------------------------------------------------------
  // 1. Jika pakai Android Emulator: gunakan "http://10.0.2.2:8000"
  // 2. Jika pakai HP Fisik (USB Debugging): gunakan IP LAN Laptop (misal "http://192.168.1.5:8000")
  // 3. Jika pakai iOS Simulator: gunakan "http://127.0.0.1:8000"
  final String baseUrl = "http://127.0.0.1:8000/api/v1";

  // POST: Login User
  // Di Laravel kita pakai 'email', bukan 'username'
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), // Endpoint sesuai routes/api.php
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Wajib agar error Laravel keluar sebagai JSON
        },
        body: json.encode({
          'email': email,       // Sesuaikan dengan controller Laravel
          'password': password,
        }),
      );

      print('Debug Status Code: ${response.statusCode}');
      print('Debug Response: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      // Laravel Sanctum mengembalikan status 200 jika sukses
      if (response.statusCode == 200) {
        // Di Laravel kita menamakan tokennya 'access_token'
        if (responseData.containsKey('access_token')) {
          return responseData; 
        } else {
          throw Exception('Login berhasil tapi token tidak ditemukan.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Email atau password salah.');
      } else {
        throw Exception('Terjadi kesalahan: ${responseData['message']}');
      }
    } catch (e) {
      print("Error pada fungsi login: $e");
      rethrow;
    }
  }

  // POST: Register User
  // Di Laravel kita butuh 'name', 'email', 'password'
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'), // Endpoint sesuai routes/api.php
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,         // 'username' diganti 'name' sesuai tabel users
          'email': email,
          'password': password,
        }),
      );

      print('Debug Register Status: ${response.statusCode}');
      print('Debug Register Body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      // Laravel create mengembalikan status 201 (Created)
      if (response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 422) {
        // Error validasi (misal email sudah terpakai)
        // Laravel mengirim error dalam bentuk object, kita ambil pesannya
        String errorMessage = responseData['message'];
        if (responseData['errors'] != null) {
            // Ambil detail error pertama jika ada
            errorMessage += " (${responseData['errors'].values.first[0]})";
        }
        throw Exception(errorMessage);
      } else {
        throw Exception('Register gagal: ${responseData['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}