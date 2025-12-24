import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // [WAJIB] Untuk kIsWeb
import 'package:movr/models/cart_model.dart'; 
import 'package:movr/services/cart_service.dart'; 
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  // --- FUNGSI HELPER URL GAMBAR (VERSI FINAL - WAJIB IMAGE-PROXY) ---
  String _getCorrectImageUrl(String? imagePath) {
    // 1. Cek Null
    if (imagePath == null || imagePath.isEmpty) {
      return "https://via.placeholder.com/150"; 
    }

    // 2. Base URL
    // Kita pakai 127.0.0.1 karena Home Page Anda sukses pakai IP ini
    String baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

    // 3. PROSES PEMBERSIHAN PATH
    String cleanPath = imagePath;

    // A. Jika input sudah berupa URL lengkap (misal: http://127.0.0.1:8000/storage/...)
    // Kita harus bongkar URL-nya dan ambil path belakangnya saja.
    if (cleanPath.startsWith('http')) {
      try {
        Uri uri = Uri.parse(cleanPath);
        cleanPath = uri.path; // Hasilnya jadi: "/storage/products/namafile.png"
      } catch (e) {
        // Jika gagal parse, biarkan cleanPath apa adanya
      }
    }

    // B. Hapus karakter '/' di depan
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // C. Hapus folder-folder awalan yang salah/dobel
    // Urutan replace ini PENTING.
    
    // Hapus 'image-proxy/' jika sudah ada (supaya tidak dobel nanti)
    if (cleanPath.startsWith('image-proxy/')) {
      cleanPath = cleanPath.replaceFirst('image-proxy/', '');
    }
    
    // Hapus 'storage/' (INI PENYEBAB UTAMA ERROR ANDA)
    if (cleanPath.startsWith('storage/')) {
      cleanPath = cleanPath.replaceFirst('storage/', '');
    }
    
    // Hapus 'public/'
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.replaceFirst('public/', '');
    }

    // 4. HASIL AKHIR: PAKSA PAKAI /image-proxy/
    // Format: http://127.0.0.1:8000/image-proxy/products/namafile.png
    return "$baseUrl/image-proxy/$cleanPath";
  }
  // ------------------------------------------------------------------

  Future<void> _fetchCartData() async {
    try {
      final result = await _cartService.getCart();
      List<dynamic> listData = result['items'] ?? []; 
      
      if (mounted) {
        setState(() {
          _cartItems = listData.map((e) => CartItem.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cart: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  String _toIDR(double amount) {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _updateQty(int index, int newQty) async {
    final item = _cartItems[index];

    // Optimistic Update
    setState(() {
       // UI update logic here if needed
    });

    try {
      await _cartService.updateCartItem(item.id, newQty); 
      _fetchCartData(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Gagal update: $e')),
      );
    }
  }

  Future<void> _deleteItem(int index) async {
    final item = _cartItems[index];
    try {
      await _cartService.deleteCartItem(item.id);
      
      setState(() {
        _cartItems.removeAt(index);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Produk dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Keranjang Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _cartItems.isEmpty
              ? const Center(child: Text("Keranjang Kosong"))
              : Column(
                  children: [
                    // LIST BARANG
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 30),
                        itemBuilder: (context, index) {
                          final item = _cartItems[index]; 
                          
                          return Row(
                            children: [
                              // --- GAMBAR PRODUK ---
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  // Panggil Helper
                                  _getCorrectImageUrl(item.product.image), 
                                  
                                  width: 80, height: 80, fit: BoxFit.cover,
                                  
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80, height: 80, 
                                      color: Colors.grey[200], 
                                      child: const Icon(Icons.broken_image, color: Colors.grey)
                                    );
                                  },
                                ),
                              ),
                              // ---------------------
                              const SizedBox(width: 12),
                              
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name, 
                                      style: const TextStyle(fontWeight: FontWeight.bold), 
                                      maxLines: 1, overflow: TextOverflow.ellipsis
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_toIDR(item.price), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Stok tersedia', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                              
                              // Counter Qty
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (item.quantity > 1) {
                                          _updateQty(index, item.quantity - 1);
                                        } else {
                                          _deleteItem(index);
                                        }
                                      },
                                      child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 16)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    InkWell(
                                      onTap: () => _updateQty(index, item.quantity + 1),
                                      child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16)),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Tombol Hapus
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteItem(index),
                              )
                            ],
                          );
                        },
                      ),
                    ),

                    // BOTTOM BAR (CHECKOUT)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(_toIDR(_totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // TOMBOL CHECKOUT
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutPage(
                                        productName: "Order (${_cartItems.length} Item)",
                                        productPrice: _totalPrice.toInt(),
                                        // PENTING: Gunakan helper di sini juga!
                                        imageUrl: _cartItems.isNotEmpty 
                                            ? _getCorrectImageUrl(_cartItems[0].product.image) 
                                            : '',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Checkout Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}