import 'package:flutter/material.dart';
import 'custom_navbar.dart';
import 'product_card.dart';
import 'product_detail_page.dart';
import 'category_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavbar(title: 'MOVR'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 250,
                      color: const Color(0xFFF2F2F2),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to MOVR',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Shop the latest products',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Cepat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoryPage()),
                      ),
                      icon: const Icon(
                        Icons.category_outlined,
                        color: Colors.black,
                      ),
                      label: const Text(
                        "Kategori",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WishlistPage()),
                      ),
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.black,
                      ),
                      label: const Text(
                        "Favorit",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Judul Produk
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Featured Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Grid Produk
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (context, index) {
                return ProductCard(
                  imageUrl:
                      'https://media.istockphoto.com/id/2183222014/id/foto/seorang-pemuda-bergaya-berpose-dengan-mantel-hitam-dan-beanie-kuning-dengan-latar-belakang.jpg?s=1024x1024&w=is&k=20&c=Iov72DTjc6ocOQwfLfywRuW0GKoQK76ZwWqa_DePRpQ=',
                  title: 'Baju Pria',
                  price: 'Rp ${(index + 1) * 10000}',
                  // Di Home, isFavorite false agar ikonnya outline
                  isFavorite: false,
                  onFavoritePressed: () {
                    // Logic: Simpan ke database/state management di sini
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sudah ada di favorite!")),
                    );
                    // Navigasi ke wishlist setelah menambah
                  },
                  onCartPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                  onCheckoutPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductDetailPage(),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
