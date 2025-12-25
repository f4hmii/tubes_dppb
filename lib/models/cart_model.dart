import 'package:flutter/foundation.dart';

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
    String rawImage = json['image'] ?? '';
    String finalImage;

    if (rawImage.isEmpty) {
      finalImage = "https://via.placeholder.com/150";
    } else if (rawImage.startsWith('http')) {
      finalImage = rawImage;
    } else {
      // Using the specified proxy path: http://127.0.0.1:8000/image-proxy/
      String baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";
      String cleanPath = rawImage.replaceAll('public/', '').replaceAll('storage/', '');
      if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
      // Don't add 'products/' again if it's already in the path
      if (!cleanPath.startsWith('products/')) {
        cleanPath = 'products/$cleanPath';
      }
      finalImage = "$baseUrl/image-proxy/$cleanPath";
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