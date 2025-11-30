import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cprujobapp/models/product_model.dart';
import 'package:cprujobapp/screens/chat_room_screen.dart';
import 'package:cprujobapp/screens/post_product_screen.dart';
import 'package:cprujobapp/widgets/product_image_slider.dart'; // ✅ ใช้ Slider

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // ฟังก์ชันทักแชทคนขาย
  Future<void> _startChat() async {
    try {
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
              targetUserId: widget.product.sellerId,
              targetUserName: userData['firstName'] ?? 'Seller',
              targetUserImage: userData['imageUrl'] ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.product.sellerId == _currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดสินค้า'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // --- Desktop View (> 900px) แบ่งครึ่ง ---
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ซ้าย: รูปภาพ
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.black,
                    height: double.infinity,
                    child: Center(
                      child: ProductImageSlider(
                        imageUrls: widget.product.imageUrls,
                      ),
                    ),
                  ),
                ),
                // ขวา: ข้อมูล
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _buildContent(context, isOwner),
                        ),
                      ),
                      _buildBottomActionBar(context, isOwner, isDesktop: true),
                    ],
                  ),
                ),
              ],
            );
          }

          // --- Mobile View เรียงลงมา ---
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.black,
                        child: ProductImageSlider(
                          imageUrls: widget.product.imageUrls,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildContent(context, isOwner),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomActionBar(context, isOwner, isDesktop: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ผู้ขาย
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                widget.product.authorAvatar.isNotEmpty
                    ? widget.product.authorAvatar
                    : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.authorName.isNotEmpty
                      ? widget.product.authorName
                      : 'ไม่ระบุชื่อ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'ผู้ขาย',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const Divider(height: 30),

        // ชื่อสินค้า & ราคา
        Text(
          widget.product.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '฿${widget.product.price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),
        // Tag สภาพสินค้า
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('สภาพ: ${widget.product.condition}'),
        ),

        const SizedBox(height: 20),
        const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    bool isOwner, {
    required bool isDesktop,
  }) {
    if (isOwner) return const SizedBox.shrink(); // เจ้าของไม่ต้องเห็นปุ่มซื้อ

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (!isDesktop)
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
        ],
        border: isDesktop
            ? const Border(top: BorderSide(color: Colors.black12))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _startChat,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('ทักแชท'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2, // ปุ่มซื้อใหญ่กว่า
            child: FilledButton.icon(
              onPressed: () {
                // Logic กดซื้อ (อาจจะทักแชทเหมือนกัน หรือจอง)
                _startChat();
              },
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('สนใจสินค้า'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
