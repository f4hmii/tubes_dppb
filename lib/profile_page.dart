import 'package:flutter/material.dart';
// Gunakan package path agar aman
import 'package:movr/services/api_service.dart';

// Pastikan file-file ini ada di folder yang sama (lib/)
import 'edit_profile_page.dart';
import 'add_address_page.dart';
import 'models/address_model.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _userProfileFuture;

  // Data User dari API
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userGender = '';

  // List Alamat (Simulasi Lokal)
  List<Address> addresses = [];

  @override
  void initState() {
    super.initState();
    // Ambil data user dari API - menggunakan ID dummy (1)
    _userProfileFuture = _getUserProfile();
  }

  Future<Map<String, dynamic>> _getUserProfile() async {
    try {
      // Panggil API User Profile
      final userProfile = await _apiService.getUserProfile(1);

      if (mounted) {
        setState(() {
          userName = userProfile['name'] != null 
              ? "${userProfile['name']['firstname']} ${userProfile['name']['lastname']}" 
              : 'User Name';
          userEmail = userProfile['email'] ?? 'user@example.com';
          userPhone = userProfile['phone'] ?? '+62 812 3456 7890';
          userGender = 'Laki-laki'; // Data gender tidak ada di API ini, kita default-kan
          
          // API FakeStore mengirim alamat, kita masukkan ke list alamat sebagai data awal
          if (userProfile['address'] != null && addresses.isEmpty) {
             final addr = userProfile['address'];
             
             // --- BAGIAN INI YANG TADI ERROR, SEKARANG SUDAH DIPERBAIKI ---
             addresses.add(Address(
               label: "Alamat Utama",
               name: "${userProfile['name']['firstname']} ${userProfile['name']['lastname']}",
               fullAddress: "${addr['street']}, No ${addr['number']}",
               city: addr['city'],
               
               // Kita tambahkan Data Dummy karena API tidak punya data ini
               province: 'Jawa Barat',        
               district: 'Kecamatan Coblong', // <-- SUDAH DITAMBAHKAN
               
               postalCode: addr['zipcode']
             ));
             // -------------------------------------------------------------
          }
        });
      }

      return userProfile;
    } catch (e) {
      // Jika API Gagal/Offline, pakai data dummy agar UI tidak rusak
      if (mounted) {
        setState(() {
          userName = 'John Doe (Offline)';
          userEmail = 'john@gmail.com';
          userPhone = '08123456789';
          userGender = 'Laki-laki';
        });
      }
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // Logika ke halaman setting
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } 
          
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 1. HEADER PROFILE
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200, width: 1),
                              image: const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Edit Profile
                      SizedBox(
                        height: 35,
                        width: 120,
                        child: OutlinedButton(
                          onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  initialName: userName,
                                  initialEmail: userEmail,
                                  initialPhone: userPhone,
                                  initialGender: userGender,
                                  onSave: (name, email, phone, gender) {
                                    setState(() {
                                      userName = name;
                                      userEmail = email;
                                      userPhone = phone;
                                      userGender = gender;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: const BorderSide(color: Colors.black),
                          ),
                          child: const Text("Edit Profil", style: TextStyle(color: Colors.black, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),

                // 2. MENU LIST (ALAMAT)
                _buildSectionHeader("Informasi Pengiriman"),

                if (addresses.isEmpty)
                  _buildMenuItem(
                    icon: Icons.add_location_alt_outlined,
                    title: "Tambah Alamat Baru",
                    subtitle: "Belum ada alamat tersimpan",
                    onTap: () => _navigateToAddAddress(),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _buildAddressItem(address, index);
                    },
                  ),

                // Tombol tambah alamat lagi
                if (addresses.isNotEmpty)
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                     child: TextButton.icon(
                       onPressed: () => _navigateToAddAddress(),
                       icon: const Icon(Icons.add, size: 16, color: Colors.black),
                       label: const Text("Tambah Alamat Lain", style: TextStyle(color: Colors.black)),
                       style: TextButton.styleFrom(
                         alignment: Alignment.centerLeft,
                         padding: EdgeInsets.zero
                       ),
                     ),
                   ),

                const Divider(thickness: 5, color: Color(0xFFF9F9F9)),

                // --- BAGIAN AKTIVITAS ---
                _buildSectionHeader("Aktivitas Saya"),
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: "Riwayat Pesanan",
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.favorite_border,
                  title: "Wishlist",
                  trailingText: "2 Item",
                  onTap: () {},
                ),

                const Divider(thickness: 5, color: Color(0xFFF9F9F9)),

                // --- BAGIAN LAINNYA ---
                _buildSectionHeader("Pusat Bantuan"),
                _buildMenuItem(
                  icon: Icons.headset_mic_outlined,
                  title: "Hubungi CS",
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                
                // Tombol Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Functions ---

  void _navigateToAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressPage(
          onAddressAdded: (newAddress) {
            setState(() {
              addresses.add(newAddress);
            });
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) 
            Text(trailingText, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildAddressItem(Address address, int index) {
    return Dismissible(
      key: Key(address.toString() + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          addresses.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alamat dihapus")));
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.location_on, color: Colors.blue, size: 20),
        ),
        title: Text(
          address.label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(address.name, style: const TextStyle(fontSize: 12, color: Colors.black)),
            Text(
              "${address.fullAddress}, ${address.city}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Icon(Icons.edit, size: 16, color: Colors.grey[400]),
      ),
    );
  }
}