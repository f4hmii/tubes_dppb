import 'package:flutter/material.dart';
import 'package:movr/services/profile_service.dart';
import 'edit_profile_page.dart';
import 'add_address_page.dart';
import 'models/address_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  late Future<Map<String, dynamic>> _userProfileFuture;

  String userName = '';
  String userEmail = '';
  List<Address> addresses = [];

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  void _refreshProfile() {
    setState(() {
      _userProfileFuture = _profileService.getProfile();
    });
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
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat profil: ${snapshot.error}"));
          }

          final userData = snapshot.data?['user'];
          final List<dynamic> alamatData = snapshot.data?['alamat'] ?? [];
          
          userName = userData?['name'] ?? 'User';
          userEmail = userData?['email'] ?? '';
          
          // PERBAIKAN 1: Mapping List yang benar (tambahkan <Address>)
          addresses = alamatData.map<Address>((a) => Address(
            id: a['id'], // Sekarang Model Address sudah punya field id
            label: a['label'] ?? '',
            name: userName,
            fullAddress: a['detail_alamat'] ?? '',
            city: a['kota'] ?? '',
            province: a['provinsi'] ?? '',
            district: a['kecamatan'] ?? '',
            postalCode: a['kode_pos'] ?? ''
          )).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 16),
                      Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(userEmail, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      const SizedBox(height: 20),
                      // PERBAIKAN 2: Tambahkan parameter yang kurang di EditProfilePage
                      SizedBox(
                        height: 35, width: 120,
                        child: OutlinedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  initialName: userName,
                                  initialEmail: userEmail,
                                  initialPhone: userData?['phone'] ?? '', // Sesuaikan jika ada field phone di Laravel
                                  initialGender: 'Laki-laki', 
                                  onSave: (name, email, phone, gender) async {
                                    bool success = await _profileService.updateProfile(name, email);
                                    if (success) _refreshProfile();
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
                // ... Sisa UI Anda tetap sama ...
                const SizedBox(height: 30),
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
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
                    itemBuilder: (context, index) => _buildAddressItem(addresses[index], index),
                  ),
                if (addresses.isNotEmpty) _buildAddMoreAddress(),
                const Divider(thickness: 5, color: Color(0xFFF9F9F9)),
                _buildSectionHeader("Aktivitas Saya"),
                _buildMenuItem(icon: Icons.shopping_bag_outlined, title: "Riwayat Pesanan", onTap: () {}),
                _buildMenuItem(icon: Icons.favorite_border, title: "Wishlist", trailingText: "0 Item", onTap: () {}),
                const SizedBox(height: 20),
                _buildLogoutButton(),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- SUB WIDGETS --- (Pastikan parameter ID digunakan di sini)
  Widget _buildAddressItem(Address address, int index) {
    return Dismissible(
      key: Key(address.id.toString()), // Sekarang .id sudah terdefinisi
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        try {
          // Sekarang destroyAlamat sudah terdefinisi di Service
          await _profileService.destroyAlamat(address.id!);
          return true;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
          return false;
        }
      },
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${address.fullAddress}, ${address.city}"),
      ),
    );
  }

  // Widget helper lainnya tetap sama...
  Widget _buildAvatar() => Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200), image: const DecorationImage(image: NetworkImage('https://ui-avatars.com/api/?name=User&background=random'), fit: BoxFit.cover)));
  void _navigateToAddAddress() { Navigator.push(context, MaterialPageRoute(builder: (context) => AddAddressPage(onAddressAdded: (newAddress) async { try { await _profileService.addAlamat({'label': newAddress.label, 'provinsi': newAddress.province, 'kota': newAddress.city, 'kecamatan': newAddress.district, 'detail_alamat': newAddress.fullAddress, 'kode_pos': newAddress.postalCode, 'is_default': false}); _refreshProfile(); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); } }))); }
  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))));
  Widget _buildMenuItem({required IconData icon, required String title, String? subtitle, String? trailingText, required VoidCallback onTap}) => ListTile(onTap: onTap, leading: Icon(icon), title: Text(title), subtitle: subtitle != null ? Text(subtitle) : null, trailing: Text(trailingText ?? ""));
  Widget _buildAddMoreAddress() => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextButton.icon(onPressed: _navigateToAddAddress, icon: const Icon(Icons.add, color: Colors.black), label: const Text("Tambah Alamat Lain", style: TextStyle(color: Colors.black))));
  Widget _buildLogoutButton() => TextButton(onPressed: () {}, child: const Text("Keluar Akun", style: TextStyle(color: Colors.red)));
}