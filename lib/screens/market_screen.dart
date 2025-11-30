import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cprujobapp/models/product_model.dart';
import 'package:cprujobapp/widgets/item_card.dart';
import 'package:cprujobapp/screens/product_detail_screen.dart';

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
        // --- 1. Filter Bar (แถบเลือกหมวดหมู่) ---
        Container(
          height: 60,
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSel = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSel,
                selectedColor: Colors.orange.shade100,
                labelStyle: TextStyle(
                  color: isSel ? Colors.orange.shade900 : Colors.black,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (v) => setState(() => _selectedCategory = cat),
              );
            },
          ),
        ),

        // --- 2. Product Grid (ตารางสินค้า) ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text(
                        'ไม่พบสินค้าในหมวดหมู่นี้',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              // Responsive Grid Layout
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2; // มือถือ = 2
                  if (constraints.maxWidth > 600) crossAxisCount = 3;
                  if (constraints.maxWidth > 900) crossAxisCount = 4;
                  if (constraints.maxWidth > 1200) crossAxisCount = 5;

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio:
                          0.7, // ปรับสัดส่วนให้การ์ดสวย (สูงกว่ากว้าง)
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      // แปลงข้อมูลเป็น Product Model
                      // (ต้องมั่นใจว่า product_model.dart มี factory fromFirestore แล้ว)
                      Product product = Product.fromFirestore(doc);

                      // ดึงรูปแรกมาโชว์
                      String thumb = product.imageUrls.isNotEmpty
                          ? product.imageUrls.first
                          : 'https://via.placeholder.com/300';

                      return ItemCard(
                        title: product.name,
                        price: product.price.toStringAsFixed(0),
                        imageUrl: thumb,

                        // ✅ ส่งชื่อคนขายไปที่ footerText หรือ authorName
                        authorName: product.authorName,
                        authorAvatar: product.authorAvatar,

                        tagText: product.condition, // มือหนึ่ง/มือสอง
                        // ✅ บังคับโชว์ชื่อคนขายด้านล่าง
                        footerText: product.authorName,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getStream() {
    Query query = FirebaseFirestore.instance.collection('market_items');

    // กรองหมวดหมู่
    if (_selectedCategory != 'ทั้งหมด') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    // เรียงลำดับ (ต้องมี Index ใน Firebase)
    return query.orderBy('created_at', descending: true).snapshots();
  }
}
