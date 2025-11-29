import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cprujobapp/screens/chat_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../widgets/full_screen_image.dart';
import 'post_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;

  Future<void> _startChat() async {
    try {
      // 1. ดึงข้อมูลเจ้าของงาน
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.product.sellerId)
          .get();

      if (!userDoc.exists) return;

      var userData = userDoc.data() as Map<String, dynamic>;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              // 👇👇 แก้ชื่อตัวแปรตรงนี้ให้ตรงกับ Error ครับ 👇👇
              targetUserId: widget.product.sellerId, // เดิมอาจเป็น targetUid
              targetUserName:
                  userData['firstName'] ?? 'User', // เดิมอาจเป็น targetName
              targetUserImage:
                  userData['imageUrl'] ?? '', // เดิมอาจเป็น targetImage
            ),
          ),
        );
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == widget.product.sellerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดสินค้า'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostProductScreen(product: widget.product),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Carousel ---
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageView(
                    imageUrls: widget.product.imageUrls,
                    initialIndex: _currentImageIndex,
                  ),
                ),
              ),
              child: Container(
                height: 350, // สินค้าควรโชว์รูปใหญ่หน่อย
                color: Colors.white,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      itemCount: widget.product.imageUrls.length,
                      onPageChanged: (index) =>
                          setState(() => _currentImageIndex = index),
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.product.imageUrls[index],
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                    if (widget.product.imageUrls.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.product.imageUrls.length,
                            (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.orange
                                      : Colors.grey[300],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.product.authorAvatar,
                        ),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.product.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.product.price.toStringAsFixed(0)} บาท',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text(widget.product.condition)),
                  const Divider(height: 30),
                  const Text(
                    'รายละเอียด',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: isOwner ? null : _startChat,
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(isOwner ? 'สินค้าของคุณ' : 'ทักแชท / สนใจสินค้า'),
          style: FilledButton.styleFrom(
            backgroundColor: isOwner ? Colors.grey : Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
