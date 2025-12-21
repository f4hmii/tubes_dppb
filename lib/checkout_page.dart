import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  // 1. DATA YANG DITERIMA DARI HALAMAN SEBELUMNYA
  final String productName;
  final String imageUrl;
  final int productPrice; // Harga dalam bentuk angka (untuk hitung total)

  const CheckoutPage({
    super.key,
    required this.productName,
    required this.imageUrl,
    required this.productPrice,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedPayment = 0;
  bool _useInsurance = false;
  bool _useCoins = false;

  // Biaya Tambahan (Statis)
  final int _shippingPrice = 12000;
  final int _insuranceFee = 2500;
  final int _appFee = 1000;
  final int _coinBalance = 15000;

  // 2. HITUNG TOTAL (Menggunakan harga asli produk yang dikirim)
  int get _totalPayment {
    int total = widget.productPrice + _shippingPrice + _appFee;
    if (_useInsurance) total += _insuranceFee;
    if (_useCoins) total -= _coinBalance;
    return total;
  }

  // Format Rupiah
  String _toIDR(int amount) {
    if (amount < 0) return '-Rp ${(-amount).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ALAMAT
                  _sectionTitle('Alamat Pengiriman', Icons.location_on_outlined),
                  const SizedBox(height: 8),
                  const Text('User MOVR | 0812-3456-7890', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Jl. Telekomunikasi No. 1, Bandung, Jawa Barat', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Divider(height: 30),

                  // PRODUK (TAMPILKAN DATA YANG DIKIRIM)
                  _sectionTitle('Rincian Produk', Icons.shopping_bag_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.imageUrl, // GAMBAR DINAMIS
                          width: 70, height: 70, fit: BoxFit.contain,
                          errorBuilder: (ctx, error, stack) => Container(color: Colors.grey[200], width: 70, height: 70, child: const Icon(Icons.error)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName, // NAMA DINAMIS
                              maxLines: 2, overflow: TextOverflow.ellipsis, 
                              style: const TextStyle(fontWeight: FontWeight.w600)
                            ),
                            const SizedBox(height: 4),
                            Text('Variasi: Standar', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_toIDR(widget.productPrice), style: const TextStyle(fontWeight: FontWeight.bold)), // HARGA DINAMIS
                                const Text('x1', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // RINGKASAN BIAYA
                  const Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _summaryRow('Subtotal Produk', widget.productPrice),
                  _summaryRow('Ongkos Kirim', _shippingPrice),
                  _summaryRow('Biaya Layanan', _appFee),
                  if (_useInsurance) _summaryRow('Asuransi', _insuranceFee),
                  if (_useCoins) _summaryRow('Diskon Koin', -_coinBalance, isDiscount: true),
                ],
              ),
            ),
          ),
          
          // BOTTOM BAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(_toIDR(_totalPayment), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan Berhasil Dibuat!")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Row(children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]);
  
  Widget _summaryRow(String title, int amount, {bool isDiscount = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      Text(_toIDR(amount), style: TextStyle(fontWeight: FontWeight.w500, color: isDiscount ? Colors.green : Colors.black, fontSize: 13)),
    ]),
  );
}