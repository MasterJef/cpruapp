import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String condition;
  final List<String> imageUrls; // List รูปภาพ
  final String sellerId;
  final String authorName; // ชื่อคนขาย
  final String authorAvatar; // รูปคนขาย
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

    List<String> images = [];
    if (data['imageUrls'] != null) {
      images = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      images.add(data['imageUrl']);
    }
    if (images.isEmpty) {
      images.add('https://via.placeholder.com/300');
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] as double?) ?? 0.0,
      category: data['category'] ?? 'อื่นๆ',
      condition: data['condition'] ?? 'มือสอง',
      imageUrls: images,
      sellerId: data['sellerId'] ?? '',
      authorName: data['authorName'] ?? 'ไม่ระบุ',
      authorAvatar:
          data['authorAvatar'] ??
          'https://cdn-icons-png.flaticon.com/512/149/149071.png',
      status: data['status'] ?? 'available',
    );
  }
}
