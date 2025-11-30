import 'package:flutter/material.dart';
import 'models/address_model.dart';

class AddAddressPage extends StatefulWidget {
  final Function(Address)? onAddressAdded;

  const AddAddressPage({Key? key, this.onAddressAdded}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    labelController.dispose();
    nameController.dispose();
    provinceController.dispose();
    cityController.dispose();
    districtController.dispose();
    villageController.dispose();
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'MOVR',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigate to cart page
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.black,
              ),
              onPressed: () {
                // Navigate to profile page
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title
              const Text(
                'Tambah Alamat Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Label Alamat
              _buildInputField(
                label: 'Label Alamat',
                controller: labelController,
                hintText: 'Contoh: Rumah, Kantor, dll',
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

              // Kelurahan
              _buildInputField(
                label: 'Kelurahan',
                controller: villageController,
                hintText: 'Masukkan kelurahan',
              ),

              const SizedBox(height: 16),

              // Alamat Lengkap
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alamat Lengkap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Masukkan alamat lengkap Anda',
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (labelController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        provinceController.text.isEmpty ||
                        cityController.text.isEmpty ||
                        districtController.text.isEmpty ||
                        villageController.text.isEmpty ||
                        addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Harap isi semua kolom'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Create Address object
                    final newAddress = Address(
                      label: labelController.text,
                      name: nameController.text,
                      province: provinceController.text,
                      city: cityController.text,
                      district: districtController.text,
                      village: villageController.text,
                      fullAddress: addressController.text,
                    );

                    // Call callback if provided
                    if (widget.onAddressAdded != null) {
                      widget.onAddressAdded!(newAddress);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alamat berhasil ditambahkan'),
                        duration: Duration(seconds: 2),
                      ),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
