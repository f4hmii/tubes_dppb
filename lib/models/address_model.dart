class Address {
  final String label;       // Rumah / Kantor
  final String name;        // Nama Penerima
  final String fullAddress; // Jalan, No Rumah
  final String district;    // <-- INI YANG HILANG (Kecamatan)
  final String city;        // Kota
  final String province;    // Provinsi
  final String postalCode;  // Kode Pos

  Address({
    required this.label,
    required this.name,
    required this.fullAddress,
    required this.district,   // <-- WAJIB ADA
    required this.city,
    required this.province,
    required this.postalCode,
  });
}