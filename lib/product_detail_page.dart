import 'package:flutter/material.dart';
import 'checkout_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productName;
  final String price;
  final String description;
  final String imageUrl;

  const ProductDetailPage({
    Key? key,
    this.productName = 'Baju Pria',
    this.price = 'Rp 100.000',
    this.description =
        'Baju pria ini memiliki desain sederhana namun tetap terlihat keren. Bahannya nyaman, ringan, dan enak dipakai seharian. Warna netral membuatnya mudah dipadukan dengan berbagai jenis celana. Cocok untuk dipakai santai maupun acara semi formal',
    this.imageUrl =
        'https://media.istockphoto.com/id/2183222014/id/foto/seorang-pemuda-bergaya-berpose-dengan-mantel-hitam-dan-beanie-kuning-dengan-latar-belakang.jpg?s=1024x1024&w=is&k=20&c=Iov72DTjc6ocOQwfLfywRuW0GKoQK76ZwWqa_DePRpQ=',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'MOVR',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              // Navigate to cart page
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.black),
              onPressed: () {
                // Navigate to profile page
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 400,
                  color: const Color(0xFFF2F2F2),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Product details
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description title
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // Description text
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Check Out',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
