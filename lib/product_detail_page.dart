import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan sudah 'flutter pub add intl'
import '../models/cart_model.dart'; // Import Model Product - Use cart_model for consistency
import 'checkout_page.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  // PERUBAHAN 1: Hapus parameter satuan string, ganti dengan Objek Product
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String _selectedSize = '';
  // ignore: unused_field
  final int _quantity = 1; 
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  // Helper untuk format rupiah (Sama seperti di Home)
  String formatRupiah(double price) {
    double finalPrice = price < 1000 ? price * 15000 : price;
    return NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    ).format(finalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // PERUBAHAN 2: Menggunakan data dari Object Product
        title: Text(widget.product.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
            ),
          )
        ],
      ),
      
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GAMBAR
                  Container(
                    height: 400,
                    width: double.infinity,
                    color: Colors.white,
                    child: Image.network(
                      widget.product.image, // Akses via Model
                      fit: BoxFit.contain, 
                      errorBuilder: (c,e,s) => const Icon(Icons.error)
                    ),
                  ),

                  // INFO PRODUK
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Format Harga Rapi
                        Text(
                          formatRupiah(widget.product.price), 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 8),
                        Text(widget.product.name, style: const TextStyle(fontSize: 16, height: 1.3)),
                        const SizedBox(height: 12),
                        const Row(children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(' 4.8  |  1.2k Terjual', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // DESKRIPSI
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.product.name, style: TextStyle(color: Colors.grey[800], height: 1.5)), // Using name as description since cart_model Product doesn't have description
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // BOTTOM BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCheckoutModal(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Keranjang', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCheckoutModal(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Beli Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Produk di Modal
                  Row(children: [
                    Image.network(widget.product.image, width: 80, height: 80, fit: BoxFit.cover),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formatRupiah(widget.product.price), // Pakai formatter lagi
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                      )
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                  ]),
                  const Divider(),
                  
                  const Text('Ukuran', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _sizes.map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _selectedSize == size,
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(color: _selectedSize == size ? Colors.white : Colors.black),
                        onSelected: (val) => setModalState(() => _selectedSize = val ? size : ''),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // PERBAIKAN LOGIKA TOMBOL BELI
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_selectedSize.isEmpty) ? null : () {
                        Navigator.pop(context); // Tutup Modal

                        // PERBAIKAN 3: Tidak perlu regex/parse string lagi!
                        // Kita punya data asli double di widget.product.price
                        // Hitung harga final (misal dikali 15000 jika data dari fakestore)
                        double finalPriceDouble = widget.product.price < 1000 
                            ? widget.product.price * 15000 
                            : widget.product.price;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              productName: widget.product.name,
                              imageUrl: widget.product.image,
                              // Kirim sebagai INT bersih ke checkout
                              productPrice: finalPriceDouble.toInt(), 
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: Text(_selectedSize.isEmpty ? 'Pilih Ukuran' : 'Beli Sekarang', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}