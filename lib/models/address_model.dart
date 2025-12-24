class Address {
  final int? id; // Wajib ada untuk identifikasi API
  final String label;
  final String name;
  final String fullAddress;
  final String city;
  final String province;
  final String district;
  final String postalCode;

  Address({
    this.id, // Tambahkan di sini
    required this.label,
    required this.name,
    required this.fullAddress,
    required this.city,
    required this.province,
    required this.district,
    required this.postalCode,
  });
}