import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String condition;
  final List<String> imageUrls;
  final String sellerId;
  final String authorName;
  final String authorAvatar;
  final String status;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.imageUrls,
    required this.sellerId,
    required this.authorName,
    required this.authorAvatar,
    required this.status,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product.fromMap(data, doc.id);
  }

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    List<String> images = [];
    if (data['imageUrls'] != null) {
      images = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      images = [data['imageUrl']];
    }

    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0.0),
      category: data['category'] ?? 'อื่นๆ',
      condition: data['condition'] ?? 'มือสอง',
      imageUrls: images,
      sellerId: data['sellerId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorAvatar: data['authorAvatar'] ?? '',
      status: data['status'] ?? 'available',
    );
  }
}
