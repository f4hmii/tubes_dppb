// Hapus import 'dart:io'; tidak perlu!

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // TIPS: Idealnya Base URL ditaruh di config global, bukan di sini.
    // Tapi untuk sementara kita pakai ini agar konsisten dengan setup kamu.
    const String baseUrl = "http://127.0.0.1:8000"; 
    
    // Logika pembersihan URL Gambar
    String rawImage = (json['image'] ?? json['image_url'] ?? '').toString().trim();
    String finalImage;

    if (rawImage.isEmpty) {
      finalImage = "https://via.placeholder.com/150"; // Gambar default jika kosong
    } else if (rawImage.startsWith('http')) {
      finalImage = rawImage;
    } else {
      // Hapus leading slash '/' jika ada untuk menghindari double slash
     if (rawImage.startsWith('/')) {
        rawImage = rawImage.substring(1);
      }
      
      // JANGAN PAKAI /storage/ LAGI
      // Ganti jadi endpoint proxy kita tadi
      finalImage = "$baseUrl/image-proxy/$rawImage";
    }

    return Product(
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? 'Tanpa Nama',
      // Menggunakan tryParse lebih aman daripada parsing langsung
      price: double.tryParse(json['price'].toString()) ?? 0.0, 
      description: json['description'] ?? 'Tidak ada deskripsi',
      image: finalImage,
      // Logika kategori kamu sudah bagus (handle object vs string)
      category: (json['category'] is Map)
          ? (json['category']['name'] ?? 'Umum')
          : (json['category']?.toString() ?? 'Umum'),
    );
  }
}