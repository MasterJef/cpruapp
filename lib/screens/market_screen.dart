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
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
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
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.75, // ปรับสัดส่วนให้สวยงาม (สูงกว่ากว้างเล็กน้อย)
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Product p = Product.fromFirestore(snapshot.data!.docs[index]);
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: p),
                      ),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Image.network(
                                p.imageUrls.first,
                                width: double.infinity,
                                fit: BoxFit.cover,
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
    var ref = FirebaseFirestore.instance
        .collection('market_items')
        .orderBy('created_at', descending: true);
    if (_selectedCategory != 'ทั้งหมด') {
      return ref.where('category', isEqualTo: _selectedCategory).snapshots();
    }
    return ref.snapshots();
  }
}
