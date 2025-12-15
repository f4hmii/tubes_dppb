import 'package:flutter/material.dart';
import 'product_card.dart';
import 'product_detail_page.dart';
import 'category_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart'; 
// import 'cart_page.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContent(),      // 0. Beranda
      const CategoryPage(),     // 1. Kategori
      const TransactionPage(),  // 2. Transaksi
      const NotificationPage(), // 3. Notifikasi
      const ProfilePage(),      // 4. Akun
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // APP BAR DINAMIS
      appBar: _selectedIndex == 0 
          ? _buildHomeAppBar() 
          : _buildSimpleAppBar(),

      body: _pages[_selectedIndex],

      // BOTTOM NAVBAR (5 ITEM)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black, 
          unselectedItemColor: Colors.grey, 
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Kategori',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }

  // --- AppBar Khusus Home ---
  PreferredSizeWidget _buildHomeAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'MOVR',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              const SizedBox(width: 16),
              
              // SEARCH BAR
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.search, color: Colors.grey[400], size: 20),
                      const SizedBox(width: 8),
                      Text('Cari...', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 1. ICON FAVORITE (PINDAH KE SINI)
              IconButton(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()));
                }, 
                icon: const Icon(Icons.favorite_border),
                color: Colors.black,
                tooltip: 'Favorit',
              ),

              // 2. ICON CART
              IconButton(
                onPressed: () {
                   // Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                }, 
                icon: const Icon(Icons.shopping_bag_outlined),
                color: Colors.black,
                tooltip: 'Keranjang',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- AppBar Sederhana ---
  PreferredSizeWidget _buildSimpleAppBar() {
    List<String> titles = ["", "Kategori Produk", "Transaksi Saya", "Notifikasi", "Profil Saya"];
    return AppBar(
      title: Text(
        titles[_selectedIndex], 
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
      ),
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      automaticallyImplyLeading: false, 
    );
  }
}

// ==========================================
// KONTEN BERANDA
// ==========================================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          
          // Banner Slider
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(
                        index == 0
                            ? 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?auto=format&fit=crop&w=800&q=80'
                            : index == 1
                                ? 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=800&q=80'
                                : 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=800&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          
          // Menu Cepat (Quick Actions)
          // "Favorit" dihapus dari sini, diganti fitur lain agar tidak duplikat
          SizedBox(
            height: 90,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickMenu(context, Icons.flash_on, 'Flash Sale', null),
                const SizedBox(width: 20),
                _buildQuickMenu(context, Icons.confirmation_number_outlined, 'Top Up', null), // Pengganti Slot Favorit
                const SizedBox(width: 20),
                _buildQuickMenu(context, Icons.local_shipping_outlined, 'Dikirim', null),
                const SizedBox(width: 20),
                _buildQuickMenu(context, Icons.discount_outlined, 'Voucher', null),
                const SizedBox(width: 20),
                _buildQuickMenu(context, Icons.diamond_outlined, 'Official', null),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Judul Featured
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Featured Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Lihat Semua')),
              ],
            ),
          ),
          
          // Grid Produk
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return ProductCard(
                imageUrl: 'https://media.istockphoto.com/id/2183222014/id/foto/seorang-pemuda-bergaya-berpose-dengan-mantel-hitam-dan-beanie-kuning-dengan-latar-belakang.jpg?s=1024x1024&w=is&k=20&c=Iov72DTjc6ocOQwfLfywRuW0GKoQK76ZwWqa_DePRpQ=',
                title: 'Fashion Pria ${index + 1}',
                price: 'Rp ${(index + 1) * 150000}',
                onFavoritePressed: () {
                    // Logic favorite inline
                },
                onCheckoutPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailPage()));
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context, IconData icon, String label, Widget? page) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================
// HALAMAN DUMMY
// ==========================================
class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Halaman Transaksi"));
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.notifications_active, color: Colors.orange),
          title: Text("Info Promo"),
          subtitle: Text("Promo belanja hemat dimulai!"),
        )
      ],
    );
  }
}