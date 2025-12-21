import 'package:flutter/material.dart';
// Import API dan Halaman Detail
import 'package:movr/services/api_service.dart';
import 'package:movr/product_detail_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final ApiService _apiService = ApiService();
  
  // Variabel untuk menampung data dari API
  List<dynamic> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistData();
  }

  // Fungsi: Ambil data API lalu ambil 5 item pertama sebagai simulasi wishlist
  Future<void> _loadWishlistData() async {
    try {
      final products = await _apiService.getAllProducts();
      if (mounted) {
        setState(() {
          // KITA AMBIL 5 PRODUK PERTAMA SEBAGAI CONTOH WISHLIST
          _wishlistItems = products.take(5).toList(); 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat wishlist: $e')),
        );
      }
    }
  }

  // Fungsi Hapus Item (Secara Lokal)
  void _removeFromWishlist(int index) {
    final removedItem = _wishlistItems[index];
    setState(() {
      _wishlistItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedItem['title']} dihapus'),
        action: SnackBarAction(
          label: 'BATAL',
          onPressed: () {
            setState(() {
              _wishlistItems.insert(index, removedItem);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Wishlist Saya",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      // LOGIKA TAMPILAN: Loading -> Kosong -> Ada Data
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _wishlistItems.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wishlistItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 30, color: Colors.transparent),
                  itemBuilder: (context, index) {
                    final item = _wishlistItems[index];
                    return _buildWishlistItem(item, index);
                  },
                ),
    );
  }

  // Widget Tampilan Item (Terkoneksi Data API)
  Widget _buildWishlistItem(dynamic item, int index) {
    // Format Harga
    final String formattedPrice = 'Rp ${(item['price'] * 15000).toStringAsFixed(0)}';

    return GestureDetector(
      onTap: () {
        // PERBAIKAN NAVIGASI KE DETAIL (Mengirim Data Lengkap)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              productName: item['title'],
              price: formattedPrice,
              description: item['description'] ?? 'No Description',
              imageUrl: item['image'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Gambar Produk dari API
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                width: 80,
                height: 80,
                fit: BoxFit.contain, // Contain agar gambar produk utuh
                errorBuilder: (ctx, error, stack) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 16),
            // Info Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2, // Maksimal 2 baris agar judul panjang muat
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating (Pengganti Size karena API tidak punya data Size)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${item['rating']['rate']} (${item['rating']['count']})",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedPrice,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
            // Tombol Delete
            IconButton(
              onPressed: () => _removeFromWishlist(index),
              icon: const Icon(Icons.favorite, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Wishlist kamu masih kosong",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}