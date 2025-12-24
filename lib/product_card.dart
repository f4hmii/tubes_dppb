import 'package:flutter/material.dart';
import '../models/cart_model.dart';

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;
  final Product product; // Add product object to access its ID
  final bool isFavorite;
  final Function(bool) onFavoritePressed; // Change to function that takes boolean
  final VoidCallback onCartPressed;
  final VoidCallback onCheckoutPressed;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.product,
    this.isFavorite = false,
    required this.onFavoritePressed,
    required this.onCartPressed,
    required this.onCheckoutPressed,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    ),
                  ),
                ),

              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    // Notify parent widget about the change
                    widget.onFavoritePressed(_isFavorite);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      // Ganti ikon berdasarkan status isFavorite
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      // Warna merah jika favorit, hitam jika tidak
                      color: _isFavorite ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Judul & Harga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),


          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onCartPressed,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.shopping_cart, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onCheckoutPressed,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text("Buy", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
