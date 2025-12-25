import 'package:flutter/material.dart';
import 'services/product_service.dart';
import 'models/category_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ProductService _productService = ProductService();
  late Future<List<ProductCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API: https://fakestoreapi.com/products/categories
    _categoriesFuture = _productService.getAllCategories();
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
      body: FutureBuilder<List<ProductCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          // 2. Error State
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          // 3. Empty State
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada kategori ditemukan'));
          }

          // 4. Success State
          final categories = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              // API mengembalikan List ProductCategory objects dengan ID dan name
              final ProductCategory category = categories[index];
              final String categoryName = category.name;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () {
                    // Gunakan category ID untuk query produk berdasarkan kategori
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Membuka kategori: $categoryName (ID: ${category.id})')),
                    );
                    // TODO: Nanti di sini bisa panggil: _productService.getProductsByCategory(category.id);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 80,
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
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        // Tampilkan nama (diterjemahkan/asli)
                        _translateCategory(categoryName).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 2))
                          ]
                        ),
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