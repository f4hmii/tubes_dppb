import 'package:flutter/material.dart';
import 'services/api_service.dart'; // Sesuaikan path import ini

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API: https://fakestoreapi.com/products/categories
    _categoriesFuture = _apiService.getAllCategories();
  }

  // Fungsi Helper: Memberikan gambar berdasarkan nama kategori dari API
  String _getCategoryImage(String category) {
    switch (category) {
      case 'electronics':
        return 'https://images.unsplash.com/photo-1498049381961-05ebc2b46624?auto=format&fit=crop&w=400&q=80';
      case 'jewelery':
        return 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=400&q=80';
      case "men's clothing":
        return 'https://images.unsplash.com/photo-1490114538077-0a7f8cb49891?auto=format&fit=crop&w=400&q=80';
      case "women's clothing":
        return 'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=400&q=80';
      default:
        return 'https://images.unsplash.com/photo-1556906781-9a412961d289?auto=format&fit=crop&w=400&q=80';
    }
  }

  // Fungsi Helper: Menerjemahkan nama kategori ke Bahasa Indonesia (Opsional)
  String _translateCategory(String category) {
    switch (category) {
      case 'electronics': return 'Elektronik';
      case 'jewelery': return 'Perhiasan';
      case "men's clothing": return 'Pakaian Pria';
      case "women's clothing": return 'Pakaian Wanita';
      default: return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kategori Produk',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // MENGGUNAKAN FUTURE BUILDER UNTUK DATA API
      body: FutureBuilder<List<dynamic>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          // 2. Error State
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // 3. Empty State
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada kategori ditemukan'));
          }

          // 4. Success State
          final categories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              // API FakeStore mengembalikan List String: ["electronics", ...]
              final String categoryName = categories[index];

              return InkWell(
                onTap: () {
                  // TODO: Nanti di sini navigasi ke halaman List Produk per Kategori
                  // Contoh: _apiService.getProductsByCategory(categoryName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Membuka kategori: $categoryName')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      // Ambil gambar berdasarkan nama kategori
                      image: NetworkImage(_getCategoryImage(categoryName)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // Overlay gelap
                      color: Colors.black.withOpacity(0.4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      // Tampilkan nama (diterjemahkan/asli)
                      _translateCategory(categoryName).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 2))
                        ]
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}