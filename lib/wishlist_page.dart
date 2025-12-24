import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan import intl
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/cart_model.dart'; // Import Model Product - Use cart_model for consistency
import 'services/wishlist_service.dart';
import 'services/product_service.dart';
import 'product_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService _wishlistService = WishlistService();
  final ProductService _productService = ProductService();

  // PERBAIKAN 1: Ubah tipe data jadi List<Product>
  List<Product> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistData();
  }

  // Helper Format Rupiah (Konsisten dengan Home)
  String formatRupiah(double price) {
    double finalPrice = price < 1000 ? price * 15000 : price;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0
    ).format(finalPrice);
  }

  Future<void> _loadWishlistData() async {
    try {
      // Try to load from API first
      final products = await _wishlistService.getWishlist();

      if (products.isNotEmpty) {
        // If API returned products, use them
        if (mounted) {
          setState(() {
            _wishlistItems = products;
            _isLoading = false;
          });
        }
      } else {
        // If API didn't return products (e.g., fallback to local storage),
        // get the favorite product IDs and fetch those products
        final prefs = await SharedPreferences.getInstance();
        final localFavoritesJson = prefs.getString('favorites') ?? '[]';
        final List<dynamic> localFavoritesList = json.decode(localFavoritesJson);
        final List<int> favoriteIds = localFavoritesList.cast<int>();

        // Fetch all products and filter by favorite IDs
        final allProducts = await _productService.getAllProducts();
        final favoriteProducts = allProducts.where((product) => favoriteIds.contains(product.id)).toList();

        if (mounted) {
          setState(() {
            _wishlistItems = favoriteProducts;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat wishlist: $e')),
        );
      }
    }
  }

  void _removeFromWishlist(int index) async {
    final removedItem = _wishlistItems[index];

    // Remove from UI immediately for better UX
    setState(() {
      _wishlistItems.removeAt(index);
    });

    try {
      // Remove from backend
      await _wishlistService.removeFromWishlist(removedItem.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${removedItem.name} dihapus dari wishlist'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'BATAL',
            onPressed: () async {
              // Add back to UI
              setState(() {
                _wishlistItems.insert(index, removedItem);
              });

              // Add back to backend
              await _wishlistService.addToWishlist(removedItem.id);
            },
          ),
        ),
      );
    } catch (e) {
      // If API call fails, add item back to list
      setState(() {
        _wishlistItems.insert(index, removedItem);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus dari wishlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Wishlist Saya",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _wishlistItems.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wishlistItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 30, color: Colors.transparent),
                  itemBuilder: (context, index) {
                    final item = _wishlistItems[index];
                    return _buildWishlistItem(item, index);
                  },
                ),
    );
  }

  // PERBAIKAN 3: Parameter item bertipe Product
  Widget _buildWishlistItem(Product item, int index) {
    return GestureDetector(
      onTap: () {
        // PERBAIKAN 4: Navigasi kirim Object Product utuh
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image, // Akses via Model
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (ctx, error, stack) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 16),
            // Info Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name, // Akses via Model - cart_model uses 'name' instead of 'title'
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating (Akses ke Nested Object Rating jika ada di Model)
                  // Jika di model rating belum ada, bisa dihapus atau di hardcode dulu
                  Row(
                    children: [
                       const Icon(Icons.star, size: 14, color: Colors.amber),
                       const SizedBox(width: 4),
                       // Asumsi model Product Anda tidak punya properti rating object terpisah 
                       // jika error, hapus baris Text ini.
                       const Text(
                         "4.8 (Review)", 
                         style: TextStyle(color: Colors.grey, fontSize: 12),
                       ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(item.price), // Pakai helper intl
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
            // Tombol Delete
            IconButton(
              onPressed: () => _removeFromWishlist(index),
              icon: const Icon(Icons.favorite, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Wishlist kamu masih kosong",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}