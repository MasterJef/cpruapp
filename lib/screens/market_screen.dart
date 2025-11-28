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
        // Filter Bar
        Container(
          height: 60,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSel = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSel,
                  onSelected: (v) => setState(() => _selectedCategory = cat),
                  selectedColor: Colors.orange[100],
                  labelStyle: TextStyle(
                    color: isSel ? Colors.orange[900] : Colors.black,
                  ),
                ),
              );
            },
          ),
        ),

        // Product Grid
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(child: Text('เกิดข้อผิดพลาด'));
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('ไม่พบสินค้าในหมวดหมู่นี้'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70, // ปรับสัดส่วนให้พอดี
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Product p = Product.fromFirestore(snapshot.data!.docs[index]);
                  // ใช้รูปแรกถ้ามี
                  String thumb = p.imageUrls.isNotEmpty
                      ? p.imageUrls.first
                      : 'https://via.placeholder.com/300';

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: p),
                      ),
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              thumb,
                              width: double.infinity,
                              fit: BoxFit.cover, // ให้รูปเต็มช่องสวยงาม
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${p.price.toStringAsFixed(0)} บ.',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        p.authorAvatar,
                                      ),
                                      radius: 8,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        p.authorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
    // 1. เริ่มต้นด้วยการอ้างอิง Collection
    Query query = FirebaseFirestore.instance.collection('market_items');

    // 2. ถ้าไม่ได้เลือก "ทั้งหมด" ให้เพิ่มเงื่อนไข where
    if (_selectedCategory != 'ทั้งหมด') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    // 3. เรียงลำดับตามเวลาล่าสุด
    // หมายเหตุ: ถ้าใช้ .where คู่กับ .orderBy อาจต้องสร้าง Index ใน Firebase Console
    return query.orderBy('created_at', descending: true).snapshots();
  }
}
