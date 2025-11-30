import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cprujobapp/widgets/item_card.dart'; // ✅ เรียกใช้ ItemCard
// import 'product_detail_screen.dart'; // อย่าลืม import หน้ารายละเอียด

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('market_items') // ตรวจสอบชื่อ collection
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Error loading market'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty)
          return const Center(child: Text('ยังไม่มีสินค้าลงขาย'));

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 คอลัมน์
            childAspectRatio: 0.75, // สัดส่วน กว้าง:สูง (ปรับให้การ์ดดูสูงสวย)
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            // ดึงข้อมูลมาใส่ ItemCard
            return ItemCard(
              title: data['name'] ?? 'สินค้า',
              price: data['price']?.toString() ?? '0',
              location:
                  data['condition'] ??
                  '', // เอาสภาพสินค้ามาใส่ช่อง Location แทน
              imageUrl: data['imageUrl'] ?? '',
              authorName: data['sellerName'] ?? 'ผู้ขาย',
              authorAvatar: data['sellerAvatar'] ?? '',
              onTap: () {
                // Navigator.push(...) // ไปหน้า ProductDetail
              },
            );
          },
        );
      },
    );
  }
}
