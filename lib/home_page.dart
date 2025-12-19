import 'package:flutter/material.dart';
import 'product_card.dart';
import 'product_detail_page.dart';
import 'category_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; 

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContent(),      
      const CategoryPage(),     
      const TransactionPage(),  
      const NotificationPage(), 
      const ProfilePage(),      
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
      // Zalora menggunakan background putih bersih, bukan grey[50]
      backgroundColor: Colors.white,

      appBar: _selectedIndex == 0 
          ? _buildHomeAppBar() 
          : _buildSimpleAppBar(),

      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black, 
          unselectedItemColor: Colors.grey[500],
          showUnselectedLabels: true,
          selectedFontSize: 10, // Font lebih kecil & elegan
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_filled)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.grid_view)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.grid_view_rounded)),
              label: 'Kategori',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.shopping_bag_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.shopping_bag)),
              label: 'Tas Belanja', // Istilah fashion
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.favorite_border)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.favorite)),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person)),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.transparent)), // Clean look
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // SEARCH BAR YANG MENDOMINASI (Ciri khas Zalora/Fashion App)
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Abu sangat muda
                    borderRadius: BorderRadius.circular(4), // Sudut tajam/sedikit round
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, color: Colors.grey[500], size: 22),
                      const SizedBox(width: 10),
                      Text('Cari di MOVR', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // ICON ACTION
              GestureDetector(
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
                 child: Stack(
                   children: [
                     const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 26),
                     Positioned(
                       right: 0,
                       top: 0,
                       child: Container(
                         padding: const EdgeInsets.all(3),
                         decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                         child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                       ),
                     )
                   ],
                 ),
              )
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSimpleAppBar() {
    return AppBar(
      title: Text(
        ["", "Kategori", "Transaksi", "Notifikasi", "Profil"][_selectedIndex],
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16)
      ),
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      automaticallyImplyLeading: false, 
    );
  }
}

// ==========================================
// KONTEN BERANDA (REFACTORED)
// ==========================================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Tab Wanita / Pria / Anak (Signature Zalora)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SEGMENT TAB (Wanita | Pria | Anak)
        Container(
          color: Colors.white,
          height: 45,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "WANITA"),
              Tab(text: "PRIA"),
              Tab(text: "ANAK"),
            ],
          ),
        ),
        
        // ISI KONTEN (Menggunakan Expanded agar bisa scroll di dalam tab)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedContent(isFemale: true), // Konten Wanita
              _buildFeedContent(isFemale: false), // Konten Pria (Dummy)
              const Center(child: Text("Kategori Anak")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedContent({required bool isFemale}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BANNER UTAMA (Full Width & Teks Overlay)
          SizedBox(
            height: 220, // Lebih tinggi
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      index == 0
                        ? (isFemale 
                            ? 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=800&q=80'
                            : 'https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?auto=format&fit=crop&w=800&q=80')
                        : 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                    ),
                    // Gradient Overlay untuk teks
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0 ? "NEW SEASON" : "FLASH SALE",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.2),
                          ),
                          const Text(
                            "Diskon hingga 50% untuk koleksi baru",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 2. KATEGORI "CIRCLE" DIGANTI "CARD" (Lebih Fashion)
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: const Text('KATEGORI POPULER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryCard('Apparel', 'https://images.unsplash.com/photo-1516762689617-e1cffcef479d?auto=format&fit=crop&w=300&q=80'),
                const SizedBox(width: 10),
                _buildCategoryCard('Shoes', 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=300&q=80'),
                const SizedBox(width: 10),
                _buildCategoryCard('Bags', 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=300&q=80'),
                const SizedBox(width: 10),
                _buildCategoryCard('Sport', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=300&q=80'),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. FEATURED PRODUCTS (Grid lebih rapi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('REKOMENDASI UNTUKMU', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                TextButton(
                  onPressed: () {}, 
                  child: const Text('LIHAT SEMUA', style: TextStyle(fontSize: 11, color: Colors.grey))
                ),
              ],
            ),
          ),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10, // Jarak antar kolom lebih rapat
              mainAxisSpacing: 20,
              childAspectRatio: 0.58, // Rasio lebih tinggi (portrait) untuk foto model
            ),
            itemBuilder: (context, index) {
              return ProductCard(
                imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=400&q=80',
                title: 'Premium Dress ${index + 1}',
                price: 'Rp ${(index + 1) * 250000}',
                onFavoritePressed: () {},
                onCheckoutPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailPage())),
                onCartPressed: () {},
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget Kategori persegi panjang (Zalora Style)
  Widget _buildCategoryCard(String label, String imgUrl) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          image: NetworkImage(imgUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.darken),
        )
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

// ==========================================
// DUMMY PAGES
// ==========================================
class TransactionPage extends StatelessWidget { const TransactionPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("Page")); }
class NotificationPage extends StatelessWidget { const NotificationPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("Page")); }