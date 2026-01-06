// Model keranjang dan produk

class Product {
  final int id;
  final String name;      
  final double price;     
  final String image;     
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Utamakan image_url jika sudah disediakan API (absolute)
    String rawImage = json['image_url'] ?? json['image'] ?? '';
    String finalImage;

    if (rawImage.isEmpty) {
      finalImage = "https://via.placeholder.com/150";
    } else if (rawImage.startsWith('http')) {
      // Paksa ke HTTPS jika host movr.kolab.top masih http
      if (rawImage.startsWith('http://movr.kolab.top')) {
        rawImage = rawImage.replaceFirst('http://', 'https://');
      }
      finalImage = rawImage;
    } else {
      // Gunakan host produksi (HTTPS) dan bersihkan prefix ganda seperlunya
      const String baseUrl = "https://movr.kolab.top";
      String cleanPath = rawImage;
      if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
      if (cleanPath.startsWith('image-proxy/')) {
        cleanPath = cleanPath.replaceFirst('image-proxy/', '');
      }
      if (cleanPath.startsWith('public/')) {
        cleanPath = cleanPath.replaceFirst('public/', '');
      }
      finalImage = "$baseUrl/$cleanPath";
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? 'Tanpa Nama',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: finalImage,
      description: json['description'] ?? json['title'] ?? json['name'] ?? 'Tidak ada deskripsi',
    );
  }
}

class CartItem {
  final int id;         
  final int quantity;   
  final double price;   
  final Product product;

  CartItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      quantity: json['jumlah'] ?? 1,
      price: double.parse((json['harga_saat_ini'] ?? 0).toString()),
      product: Product.fromJson(json['produk']),
    );
  }
}   