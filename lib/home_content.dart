import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// PENTING: Gunakan cart_model.dart, jangan impor product_model.dart
import '../models/cart_model.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'product_card.dart';
import 'product_detail_page.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();

  // Pastikan tipe data List<Product> berasal dari cart_model.dart
  late Future<List<Product>> _productsFuture;

  // Keep track of favorite status for each product
  final Map<int, bool> _favoriteStatus = {};

  @override
  void initState() {
    super.initState();
    // Memanggil API produk
    _productsFuture = _loadProductsAndFavorites();
  }

  // Load products and check their favorite status
  Future<List<Product>> _loadProductsAndFavorites() async {
    final products = await _productService.getAllProducts();

    // Check favorite status for each product
    for (final product in products) {
      _favoriteStatus[product.id] = await _wishlistService.isInWishlist(product.id);
    }

    return products;
  }

  // Fungsi untuk menangani penambahan ke keranjang
  Future<void> _handleAddToCart(Product product) async {
    try {
      // Mengirim ID produk ke backend Laravel
      await _cartService.addToCart(product.id, 1);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} berhasil ditambah ke keranjang'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah ke keranjang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menangani penambahan ke wishlist
  Future<void> _handleAddToWishlist(Product product) async {
    try {
      await _wishlistService.addToWishlist(product.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan ke wishlist'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah ke wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menangani penghapusan dari wishlist
  Future<void> _handleRemoveFromWishlist(Product product) async {
    try {
      await _wishlistService.removeFromWishlist(product.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} dihapus dari wishlist'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus dari wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatRupiah(double price) {
    // Logika penyesuaian harga jika data berasal dari API dummy
    double finalPrice = price < 1000 ? price * 15000 : price;
    
    return NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    ).format(finalPrice);
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

          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200, 
                  child: Center(child: CircularProgressIndicator(color: Colors.black))
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Gagal memuat data: ${snapshot.error}"),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Tidak ada produk tersedia"));
              }

              final products = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length > 6 ? 6 : products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ProductCard(
                    product: product,
                    imageUrl: product.image,
                    title: product.name,
                    price: formatRupiah(product.price),
                    isFavorite: _favoriteStatus[product.id] ?? false, // Use actual favorite status
                    onFavoritePressed: (isFavorite) {
                      // Update local favorite status
                      setState(() {
                        _favoriteStatus[product.id] = isFavorite;
                      });

                      // Call the appropriate service method
                      if (isFavorite) {
                        // Add to wishlist
                        _handleAddToWishlist(product);
                      } else {
                        // Remove from wishlist
                        _handleRemoveFromWishlist(product);
                      }
                    },
                    onCartPressed: () => _handleAddToCart(product),
                    onCheckoutPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product),
                        ),
                      );
                    },
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

  // --- WIDGET HELPER ---

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
            errorBuilder: (c,e,s) => Container(color: Colors.grey),
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
                const Text(
                  "JUST DO IT",
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 28, 
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.2
                  ),
                ),
                const Text(
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
          width: 55, height: 55,
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