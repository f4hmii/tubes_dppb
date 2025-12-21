import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'product_card.dart';
import 'product_detail_page.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ApiService _apiService = ApiService(); // Panggil Service
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Panggil HTTP Request ke-1 saat aplikasi dibuka
    _productsFuture = _apiService.getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerSection(),
          const SizedBox(height: 30),
          _buildCategorySection(),
          const SizedBox(height: 30),
          _buildProductHeader(),
          
          // GANTI GRIDVIEW DENGAN FUTURE BUILDER (HTTP)
          FutureBuilder<List<dynamic>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // Loading
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Tidak ada produk"));
              }

              // Jika data ada
              final products = snapshot.data!;
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length > 6 ? 6 : products.length, // Tampilkan 6 saja biar rapi
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  
                  // --- PERBAIKAN LOGIKA HARGA (SAFE PARSING) ---
                  // Kita pastikan harga diubah ke angka (num) dulu, baru dikali
                  // Jika error/null, anggap harganya 0
                  num hargaAngka = num.tryParse(product['price'].toString()) ?? 0;
                  final formattedPrice = 'Rp ${(hargaAngka * 15000).toStringAsFixed(0)}';
                  // ---------------------------------------------

                  return ProductCard(
                    imageUrl: product['image'], 
                    title: product['title'],
                    price: formattedPrice, 
                    onFavoritePressed: () {},
                    onCheckoutPressed: () {
                       Navigator.push(
                         context, 
                         MaterialPageRoute(
                           builder: (_) => ProductDetailPage(
                             productName: product['title'],
                             price: formattedPrice,
                             description: product['description'] ?? 'Tidak ada deskripsi',
                             imageUrl: product['image'],
                           )
                         )
                       );
                    },
                    onCartPressed: () {},
                  );
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- BAGIAN BANNER & KATEGORI TETAP SAMA (DUMMY SPORTY) ---
  
  Widget _buildBannerSection() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80', 
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          const Positioned(
            bottom: 20,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "JUST DO IT",
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 28, 
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.2
                  ),
                ),
                Text(
                  "Perlengkapan olahraga profesional",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Lari', 'icon': Icons.directions_run},
      {'label': 'Gym', 'icon': Icons.fitness_center},
      {'label': 'Bola', 'icon': Icons.sports_soccer},
      {'label': 'Basket', 'icon': Icons.sports_basketball},
      {'label': 'Renang', 'icon': Icons.pool},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('KATEGORI OLAHRAGA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((cat) {
              return _buildCategoryCard(cat['label'] as String, cat['icon'] as IconData);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 55, 
          height: 55,
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('FLASH SALE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          TextButton(onPressed: () {}, child: const Text('LIHAT SEMUA', style: TextStyle(fontSize: 11, color: Colors.grey))),
        ],
      ),
    );
  }
}