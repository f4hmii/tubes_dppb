import 'package:flutter/material.dart';
import 'package:movr/services/api_service.dart'; // Import API Service
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiService _apiService = ApiService();
  
  // Data Keranjang (Dinamis)
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  // FUNGSI UTAMA: Mengambil Cart + Detail Produk
  Future<void> _fetchCartData() async {
    try {
      // 1. Ambil Data Cart dari API (User ID 1 sebagai simulasi)
      final carts = await _apiService.getUserCart(1);
      
      if (carts.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Ambil keranjang pertama yang aktif
      final List<dynamic> productsInCart = carts[0]['products'];

      // 2. Siapkan wadah untuk data lengkap
      List<Map<String, dynamic>> detailedItems = [];

      // 3. LOOPING: Ambil detail (Nama, Gambar, Harga) untuk setiap produk
      // Kita pakai Future.wait agar request berjalan paralel (lebih cepat)
      final futures = productsInCart.map((item) async {
        final productDetail = await _apiService.getProductDetail(item['productId']);
        
        // Konversi Harga USD ke IDR (x 15.000) agar terlihat realistis
        int priceIDR = ((productDetail['price'] as num) * 15000).toInt();

        return {
          'id': productDetail['id'],
          'name': productDetail['title'],
          'price': priceIDR, 
          'image': productDetail['image'],
          'quantity': item['quantity'],
          'size': 'All Size', // Data dummy karena API tidak punya size
        };
      });

      // Tunggu semua data selesai diambil
      detailedItems = await Future.wait(futures);

      // 4. Update UI
      if (mounted) {
        setState(() {
          _cartItems = detailedItems;
          _isLoading = false;
        });
      }

    } catch (e) {
      print("Error fetching cart: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hitung Total Harga
  int get _totalPrice {
    int total = 0;
    for (var item in _cartItems) {
      total += (item['price'] as int) * (item['quantity'] as int);
    }
    return total;
  }

  String _toIDR(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _incrementQty(int index) {
    setState(() {
      _cartItems[index]['quantity']++;
    });
  }

  void _decrementQty(int index) {
    setState(() {
      if (_cartItems[index]['quantity'] > 1) {
        _cartItems[index]['quantity']--;
      } else {
        _cartItems.removeAt(index);
      }
    });
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
      // TAMPILAN LOADING ATAU LIST DATA
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
                              // Gambar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['image'],
                                  width: 80, height: 80, fit: BoxFit.contain,
                                  errorBuilder: (c,e,s) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.error)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'], 
                                      style: const TextStyle(fontWeight: FontWeight.bold), 
                                      maxLines: 1, overflow: TextOverflow.ellipsis
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_toIDR(item['price']), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Size: ${item['size']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
                                      onTap: () => _decrementQty(index),
                                      child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 16)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    InkWell(
                                      onTap: () => _incrementQty(index),
                                      child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16)),
                                    ),
                                  ],
                                ),
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
                                        // Kirim Gabungan Data Keranjang ke Checkout
                                        productName: "Order Keranjang (${_cartItems.length} Item)",
                                        productPrice: _totalPrice,
                                        imageUrl: _cartItems.isNotEmpty 
                                            ? _cartItems[0]['image'] 
                                            : 'https://via.placeholder.com/150',
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