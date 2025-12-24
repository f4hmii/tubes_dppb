import 'package:flutter/material.dart';
import 'models/address_model.dart'; // Pastikan path ini benar

class AddAddressPage extends StatefulWidget {
  final Function(Address)? onAddressAdded;

  const AddAddressPage({super.key, this.onAddressAdded});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  // GANTI KELURAHAN JADI KODE POS AGAR SESUAI MODEL
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    labelController.dispose();
    nameController.dispose();
    provinceController.dispose();
    cityController.dispose();
    districtController.dispose();
    postalCodeController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Alamat',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Isi Detail Alamat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              // Label Alamat
              _buildInputField(
                label: 'Label Alamat',
                controller: labelController,
                hintText: 'Contoh: Rumah, Kantor, Kosan',
              ),

              const SizedBox(height: 16),

              // Nama Penerima
              _buildInputField(
                label: 'Nama Penerima',
                controller: nameController,
                hintText: 'Masukkan nama penerima',
              ),

              const SizedBox(height: 16),

              // Provinsi
              _buildInputField(
                label: 'Provinsi',
                controller: provinceController,
                hintText: 'Masukkan nama provinsi',
              ),

              const SizedBox(height: 16),

              // Kabupaten/Kota
              _buildInputField(
                label: 'Kabupaten/Kota',
                controller: cityController,
                hintText: 'Masukkan kabupaten/kota',
              ),

              const SizedBox(height: 16),

              // Kecamatan
              _buildInputField(
                label: 'Kecamatan',
                controller: districtController,
                hintText: 'Masukkan kecamatan',
              ),

              const SizedBox(height: 16),

              // Kode Pos (PENGGANTI KELURAHAN)
              _buildInputField(
                label: 'Kode Pos',
                controller: postalCodeController,
                hintText: 'Masukkan kode pos',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Alamat Lengkap
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alamat Lengkap (Jalan, No. Rumah, RT/RW)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Jl. Sukabiryu No. 10, RT 01/02',
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Validasi Input
                    if (labelController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        provinceController.text.isEmpty ||
                        cityController.text.isEmpty ||
                        districtController.text.isEmpty ||
                        postalCodeController.text.isEmpty ||
                        addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Harap isi semua kolom'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // MEMBUAT OBJEK ADDRESS (SESUAI MODEL TERBARU)
                    final newAddress = Address(
                      label: labelController.text,
                      name: nameController.text,
                      province: provinceController.text,
                      city: cityController.text,
                      district: districtController.text,
                      postalCode: postalCodeController.text, 
                      fullAddress: addressController.text,
                    );

                    // Kirim data balik ke ProfilePage
                    if (widget.onAddressAdded != null) {
                      widget.onAddressAdded!(newAddress);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alamat berhasil disimpan')),
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Simpan Alamat',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}