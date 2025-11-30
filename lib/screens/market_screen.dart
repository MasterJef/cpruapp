import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

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
        // --- Filter Bar (Design เดิมแต่สะอาดขึ้น) ---
        Container(
          height: 50,
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSel = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSel
                        ? const Color(0xFFE64A19).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: isSel
                        ? Border.all(color: const Color(0xFFE64A19))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSel ? const Color(0xFFE64A19) : Colors.black87,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // --- Product Grid ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text('เกิดข้อผิดพลาด'));
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());

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

              // Responsive Layout Builder
              return LayoutBuilder(
                builder: (context, constraints) {
                  // คำนวณจำนวนคอลัมน์: จอเล็ก 2, จอกลาง 3-4, จอใหญ่ 5-6
                  int crossAxisCount = 2;
                  if (constraints.maxWidth > 600) crossAxisCount = 3;
                  if (constraints.maxWidth > 900) crossAxisCount = 4;
                  if (constraints.maxWidth > 1200) crossAxisCount = 5;

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio:
                          0.65, // ปรับสัดส่วนให้การ์ดสูงพอดีกับเนื้อหา (แนวตั้ง)
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final product = Product.fromFirestore(
                        snapshot.data!.docs[index],
                      );
                      String thumb = product.imageUrls.isNotEmpty
                          ? product.imageUrls.first
                          : 'https://via.placeholder.com/300';

                      return ItemCard(
                        title: product.name,
                        price:
                            '฿${product.price.toStringAsFixed(0)}', // ใส่สกุลเงิน
                        imageUrl: thumb,
                        tagText: product.condition, // เช่น มือสอง
                        footerText: product.authorName, // ชื่อคนขาย
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
    var ref = FirebaseFirestore.instance
        .collection('market_items')
        .orderBy('created_at', descending: true);
    if (_selectedCategory != 'ทั้งหมด') {
      return ref.where('category', isEqualTo: _selectedCategory).snapshots();
    }
    return ref.snapshots();
  }
}
