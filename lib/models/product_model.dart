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
    const String baseUrl = "https://movr.kolab.top"; 
    
    // Logika pembersihan URL Gambar
    // Utamakan image_url dari API (sudah absolute dari accessor Laravel)
    String rawImage = (json['image_url'] ?? json['image'] ?? '').toString().trim();
    String finalImage;

    if (rawImage.isEmpty) {
      finalImage = "https://via.placeholder.com/150"; // Gambar default jika kosong
    } else if (rawImage.startsWith('http')) {
      // Paksa ke HTTPS jika host movr.kolab.top masih http
      if (rawImage.startsWith('http://movr.kolab.top')) {
        rawImage = rawImage.replaceFirst('http://', 'https://');
      }
      finalImage = rawImage;
    } else {
      // Hapus leading slash '/' jika ada untuk menghindari double slash
     if (rawImage.startsWith('/')) {
        rawImage = rawImage.substring(1);
      }
      // Bersihkan prefix yang tidak diperlukan namun jangan hapus path storage
      if (rawImage.startsWith('image-proxy/')) {
        rawImage = rawImage.replaceFirst('image-proxy/', '');
      }
      if (rawImage.startsWith('public/')) {
        rawImage = rawImage.replaceFirst('public/', '');
      }
      // Build URL langsung ke host produksi
      finalImage = "$baseUrl/$rawImage";
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