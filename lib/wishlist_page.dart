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
      'title': 'Item Favorit ${index + 1}',
      'price': 'Rp ${(index + 1) * 25000}',
      'imageUrl':
          'https://media.istockphoto.com/id/2183222014/id/foto/seorang-pemuda-bergaya-berpose-dengan-mantel-hitam-dan-beanie-kuning-dengan-latar-belakang.jpg?s=1024x1024&w=is&k=20&c=Iov72DTjc6ocOQwfLfywRuW0GKoQK76ZwWqa_DePRpQ=',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorit Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _favoriteItems.isEmpty
          ? const Center(child: Text("Belum ada produk favorit"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (context, index) {
                final item = _favoriteItems[index];
                return ProductCard(
                  imageUrl: item['imageUrl'],
                  title: item['title'],
                  price: item['price'],
                  // Di halaman ini, semua item pasti favorit, jadi true
               

                  // Aksi Hapus dari Favorit
                  onFavoritePressed: () {
                    setState(() {
                      _favoriteItems.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Produk dihapus dari favorit"),
                        duration: Duration(seconds: 1),
                      ),
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
    );
  }
}