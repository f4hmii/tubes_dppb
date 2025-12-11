import 'package:flutter/material.dart';
import 'product_card.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
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
            title: 'Item Favorit ${index + 1}',
            price: 'Rp ${(index + 1) * 25000}',
            
            onFavoritePressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sudah ada di favorit!")),
              );
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
                MaterialPageRoute(builder: (context) => const ProductDetailPage()),
              );
            },
          );
        },
      ),
    );
  }
}