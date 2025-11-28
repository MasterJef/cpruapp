// lib/screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // แนะนำให้ลง intl เพิ่มใน pubspec.yaml เพื่อจัดรูปแบบเงิน
import 'product_detail_screen.dart';

// --- Product Model (ใส่ไว้ที่นี่เพื่อความสะดวก หรือแยกไฟล์ก็ได้) ---
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String condition; // 'มือหนึ่ง', 'มือสอง'
  final String imageUrl;
  final String sellerId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.imageUrl,
    required this.sellerId,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] as double?) ?? 0.0,
      category: data['category'] ?? 'อื่นๆ',
      condition: data['condition'] ?? 'มือสอง',
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/300',
      sellerId: data['sellerId'] ?? '',
    );
  }
}
// -----------------------------------------------------------

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = 'ทั้งหมด';
  final List<String> _categories = [
    'ทั้งหมด',
    'เสื้อผ้า',
    'หนังสือ',
    'อุปกรณ์ไอที',
    'ของใช้',
    'อื่นๆ',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. Filter Bar ---
        Container(
          height: 60,
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: Colors.orange.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.orange.shade900 : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (bool selected) {
                  if (selected) setState(() => _selectedCategory = category);
                },
              );
            },
          ),
        ),

        // --- 2. Product Grid ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text('โหลดข้อมูลไม่สำเร็จ'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront, size: 60, color: Colors.grey),
                      Text(
                        'ยังไม่มีสินค้าในหมวดนี้',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 คอลัมน์
                  childAspectRatio: 0.70, // สัดส่วน สูงกว่ากว้าง (แนวตั้ง)
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final product = Product.fromFirestore(
                    snapshot.data!.docs[index],
                  );
                  return _buildProductCard(context, product);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getStream() {
    Query query = FirebaseFirestore.instance
        .collection('market_items')
        .orderBy('created_at', descending: true);

    if (_selectedCategory != 'ทั้งหมด') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    return query.snapshots();
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // ใช้ NumberFormat จัดรูปแบบเงิน (ถ้าไม่ได้ลง intl ให้ใช้ '${product.price} บ.')
    // final formatCurrency = NumberFormat("#,##0", "th_TH");

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปสินค้า
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                  // ป้ายสภาพสินค้า
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // รายละเอียด
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} บาท',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
