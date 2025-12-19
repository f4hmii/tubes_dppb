import 'package:flutter/material.dart';
import 'product_card.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // Simulasi data produk favorit
  final List<Map<String, dynamic>> _favoriteItems = List.generate(
    4,
    (index) => {
      'id': index,
      'title': 'Fashion Pria ${index + 1}',
      'price': 'Rp ${(index + 1) * 150000}',
      'imageUrl':
          'https://media.istockphoto.com/id/2183222014/id/foto/seorang-pemuda-bergaya-berpose-dengan-mantel-hitam-dan-beanie-kuning-dengan-latar-belakang.jpg?s=1024x1024&w=is&k=20&c=Iov72DTjc6ocOQwfLfywRuW0GKoQK76ZwWqa_DePRpQ=',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background konsisten dengan Home
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Shadow tipis
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wishlist Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
               // Navigasi ke keranjang (opsional)
               Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
            },
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
          ),
        ],
      ),
      body: _favoriteItems.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12, // Spacing disesuaikan dengan Home
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, // Rasio disesuaikan agar proporsional
              ),
              itemBuilder: (context, index) {
                final item = _favoriteItems[index];
                return ProductCard(
                  imageUrl: item['imageUrl'],
                  title: item['title'],
                  price: item['price'],
                  // Logic: Karena ini halaman Wishlist, tombol hati akan menghapus item
                  onFavoritePressed: () {
                    _removeFromWishlist(index);
                  },
                  onCheckoutPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductDetailPage(),
                      ),
                    );
                  },
                  onCartPressed: () {
                    // Add item to cart functionality
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                  },
                );
              },
            ),
    );
  }

  // Widget tampilan jika Wishlist kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Wah, wishlist kamu kosong!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            "Yuk, cari barang impianmu sekarang.",
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Cari Barang", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _removeFromWishlist(int index) {
    setState(() {
      _favoriteItems.removeAt(index);
    });
    
    // Tampilkan notifikasi (SnackBar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Produk dihapus dari wishlist"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating, // Melayang di atas bottom navbar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.yellow,
          onPressed: () {
            // Logic Undo bisa ditambahkan di sini jika mau
          },
        ),
      ),
    );
  }
}