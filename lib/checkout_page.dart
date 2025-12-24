import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Wajib import ini agar format Rupiah konsisten

class CheckoutPage extends StatefulWidget {
  // Kita tetap terima primitive types (String/Int) disini agar fleksibel
  // (Bisa dipanggil dari DetailProduk atau Keranjang nanti)
  final String productName;
  final String imageUrl;
  final int productPrice; 

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
  // ignore: unused_field
  final int _selectedPayment = 0;
  bool _useInsurance = false;
  bool _useCoins = false;

  // Biaya Tambahan (Statis)
  final int _shippingPrice = 12000;
  final int _insuranceFee = 2500;
  final int _appFee = 1000;
  final int _coinBalance = 15000;

  // 2. HITUNG TOTAL 
  int get _totalPayment {
    int total = widget.productPrice + _shippingPrice + _appFee;
    
    if (_useInsurance) total += _insuranceFee;
    if (_useCoins) total -= _coinBalance;
    
    // PROTEKSI: Jangan sampai total bayar minus (kalau diskon kegedean)
    return total < 0 ? 0 : total;
  }

  // REFACTOR: Gunakan Library intl agar sama dengan halaman Home
  String _formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
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

                  // PRODUK 
                  _sectionTitle('Rincian Produk', Icons.shopping_bag_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.imageUrl, 
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
                              widget.productName, 
                              maxLines: 2, overflow: TextOverflow.ellipsis, 
                              style: const TextStyle(fontWeight: FontWeight.w600)
                            ),
                            const SizedBox(height: 4),
                            Text('Variasi: Standar', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatRupiah(widget.productPrice), style: const TextStyle(fontWeight: FontWeight.bold)), 
                                const Text('x1', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // OPSI TAMBAHAN (Interaktif)
                  _buildSwitchOption("Asuransi Pengiriman", _insuranceFee, _useInsurance, (val) {
                    setState(() => _useInsurance = val);
                  }),
                  _buildSwitchOption("Tukar Koin MOVR", -_coinBalance, _useCoins, (val) {
                    setState(() => _useCoins = val);
                  }, isDiscount: true),

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
                      Text(_formatRupiah(_totalPayment), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan Berhasil Dibuat!")));
                      // Di sini nanti logika kirim data ke API Laravel (POST Order)
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
  
  // Widget Switch untuk Asuransi & Koin
  Widget _buildSwitchOption(String title, int amount, bool value, Function(bool) onChanged, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            Text(
               isDiscount ? "-${_formatRupiah(amount.abs())}" : _formatRupiah(amount), 
               style: TextStyle(fontSize: 12, color: Colors.grey[600])
            ),
          ],
        ),
        Switch(
          value: value, 
          onChanged: onChanged,
          activeColor: Colors.black,
        )
      ],
    );
  }

  Widget _summaryRow(String title, int amount, {bool isDiscount = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      Text(
        _formatRupiah(amount), 
        style: TextStyle(fontWeight: FontWeight.w500, color: isDiscount ? Colors.green : Colors.black, fontSize: 13)
      ),
    ]),
  );
}