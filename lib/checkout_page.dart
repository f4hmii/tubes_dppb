import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // --- STATE VARIABLES (Untuk Logika Dinamis) ---
  int _selectedPaymentIndex = 0;
  bool _useInsurance = false;
  bool _useCoins = false;

  // Data Dummy Harga
  final int _productPrice = 350000;
  final int _shippingPrice = 12000;
  final int _serviceFee = 1000;
  final int _insuranceFee = 2500;
  final int _coinBalance = 15000; // Saldo koin user

  // --- LOGIKA HITUNG TOTAL ---
  int get _totalPayment {
    int total = _productPrice + _shippingPrice + _serviceFee;
    if (_useInsurance) total += _insuranceFee;
    if (_useCoins) total -= _coinBalance;
    return total;
  }

  // Helper untuk format Rupiah (Manual tanpa plugin intl agar copy-paste friendly)
  String _formatCurrency(int amount) {
    var str = amount.toString(); 
    if (amount < 0) str = str.replaceAll('-', ''); // Handle negatif
    String result = 'Rp ${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    return amount < 0 ? '-$result' : result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. ALAMAT
                  _buildAddressSection(),
                  
                  // 2. PRODUK (Sudah diperbaiki TextField-nya)
                  _buildProductSection(),

                  // 3. PENGIRIMAN & ASURANSI
                  _buildShippingSection(),

                  // 4. VOUCHER & KOIN (Fitur Baru)
                  _buildPromoAndCoinsSection(),

                  // 5. METODE PEMBAYARAN
                  _buildPaymentMethodSection(),

                  // 6. RINCIAN BIAYA
                  _buildCostSummarySection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // 7. BOTTOM BAR (Total Harga Dinamis)
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // --- WIDGET SECTIONS ---

  Widget _buildAddressSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Garis Amplop
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.blue, Colors.red, Colors.blue],
                stops: [0.0, 0.2, 0.2, 1.0],
                tileMode: TileMode.repeated,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, color: Colors.black54, size: 18),
                        SizedBox(width: 8),
                        Text('Alamat Pengiriman', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('Ubah', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Rizky User', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('|  (+62) 812-3456-7890', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Jl. Teknologi No. 10, Gedung Kreatif Lt. 2, Bandung, Jawa Barat, 40287',
                  style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.storefront, size: 18),
              SizedBox(width: 8),
              Text('MOVR Official Store', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.verified, color: Colors.blue, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  'https://media.istockphoto.com/id/2183222014/id/foto/seorang-pemuda-bergaya-berpose-dengan-mantel-hitam-dan-beanie-kuning-dengan-latar-belakang.jpg?s=1024x1024&w=is&k=20&c=Iov72DTjc6ocOQwfLfywRuW0GKoQK76ZwWqa_DePRpQ=',
                  width: 70, height: 70, fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Oversized Streetwear Black Coat', maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Variasi: Hitam, XL', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatCurrency(_productPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('x1', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // --- PERBAIKAN TEXT FIELD DI SINI ---
          TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Silakan tinggalkan pesan..',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              // Menggunakan UnderlineInputBorder, bukan langsung BorderSide
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Opsi Pengiriman', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('Reguler (JNE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  const Text('Estimasi 2-3 Hari', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  Text(_formatCurrency(_shippingPrice), style: const TextStyle(fontSize: 13)),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ],
              )
            ],
          ),
          const Divider(height: 24),
          // Checkbox Asuransi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Proteksi Kerusakan +", style: TextStyle(fontSize: 13)),
                    Text("Lindungi produkmu dari kerusakan", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(_formatCurrency(_insuranceFee), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Checkbox(
                    activeColor: Colors.black,
                    value: _useInsurance,
                    onChanged: (val) {
                      setState(() {
                        _useInsurance = val ?? false;
                      });
                    },
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPromoAndCoinsSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                const Text("Voucher Toko", style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Text("Pilih Voucher", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_outlined, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tukarkan Koin", style: TextStyle(fontSize: 14)),
                    Text("Saldo: ${_formatCurrency(_coinBalance)}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Switch(
                  activeColor: Colors.black,
                  value: _useCoins,
                  onChanged: (val) {
                    setState(() {
                      _useCoins = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("Lihat Semua", style: TextStyle(color: Colors.black, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          _paymentOption(0, 'Transfer Bank - BCA', 'Dicek Otomatis'),
          _paymentOption(1, 'E-Wallet (Gopay)', 'Bebas Biaya Admin'),
        ],
      ),
    );
  }

  Widget _paymentOption(int index, String title, String subtitle) {
    bool isSelected = _selectedPaymentIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.grey[50] : Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: isSelected ? Colors.black : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.black : Colors.grey[800])),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummarySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.receipt_long, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow('Subtotal untuk Produk', _formatCurrency(_productPrice)),
          _summaryRow('Subtotal Pengiriman', _formatCurrency(_shippingPrice)),
          _summaryRow('Biaya Layanan', _formatCurrency(_serviceFee)),
          
          if (_useInsurance) 
            _summaryRow('Biaya Asuransi', _formatCurrency(_insuranceFee)),
          
          if (_useCoins) 
            _summaryRow('Diskon Koin', _formatCurrency(-_coinBalance), isGreen: true),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatCurrency(_totalPayment), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: TextStyle(color: isGreen ? Colors.green : Colors.black, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(_formatCurrency(_totalPayment), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          SizedBox(
            width: 140,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Column(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 50),
                        SizedBox(height: 10),
                        Text("Pesanan Berhasil"),
                      ],
                    ),
                    content: const Text("Terima kasih telah berbelanja di MOVR.", textAlign: TextAlign.center),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: const Text("OK", style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}