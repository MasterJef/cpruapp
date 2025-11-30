import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // เผื่อใช้ลบ
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

  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบสินค้า'),
        content: const Text('ต้องการลบสินค้านี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('market_items')
          .doc(widget.product.id)
          .delete();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบสินค้าแล้ว')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == widget.product.sellerId;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          appBar: AppBar(
            title: const Text('รายละเอียดสินค้า'),
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PostProductScreen(product: widget.product),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProduct(context),
                ),
              ],
            ],
          ),
          body: isDesktop
              ? _buildDesktopLayout(context, isOwner)
              : _buildMobileLayout(context, isOwner),

          bottomNavigationBar: isDesktop
              ? null
              : _buildBottomAction(context, isOwner, isMobile: true),
        );
      },
    );
  }

  // --- Layouts ---

  Widget _buildDesktopLayout(BuildContext context, bool isOwner) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.black,
            child: _buildImageGallery(isDesktop: true),
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: _buildProductInfo(),
                ),
              ),
              _buildBottomAction(context, isOwner, isMobile: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isOwner) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(isDesktop: false),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildProductInfo(),
          ),
        ],
      ),
    );
  }

  // --- Components ---

  Widget _buildImageGallery({required bool isDesktop}) {
    final double? height = isDesktop ? double.infinity : 350;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageView(
              imageUrls: widget.product.imageUrls,
              initialIndex: _currentImageIndex,
            ),
          ),
        );
      },
      child: Container(
        height: height,
        color: Colors
            .white, // สินค้าพื้นหลังขาวอาจจะสวยกว่า แต่ถ้าอยากได้ดำก็เปลี่ยนได้
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
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
            if (widget.product.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.product.imageUrls.length, (
                    index,
                  ) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? const Color(0xFFE64A19)
                            : Colors.grey[300],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.product.authorAvatar),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
        const Divider(height: 40),

        // Price & Title
        Text(
          '${widget.product.price.toStringAsFixed(0)} บาท',
          style: const TextStyle(
            color: Color(0xFFE64A19),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Tags
        Wrap(
          spacing: 8,
          children: [
            Chip(
              label: Text(widget.product.condition),
              backgroundColor: Colors.grey[200],
            ),
            Chip(
              label: Text(widget.product.category),
              backgroundColor: Colors.grey[200],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Description
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

  Widget _buildBottomAction(
    BuildContext context,
    bool isOwner, {
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isMobile
            ? [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
        border: !isMobile
            ? Border(top: BorderSide(color: Colors.grey.shade200))
            : null,
      ),
      child: FilledButton.icon(
        onPressed: isOwner
            ? null
            : () {
                // Logic เปิดหน้าแชท (ถ้ามี Chat Screen)
                // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(...)));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ฟีเจอร์ Chat กำลังเชื่อมต่อ...'),
                  ),
                );
              },
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(isOwner ? 'สินค้าของคุณเอง' : 'ทักแชท / สนใจสินค้า'),
        style: FilledButton.styleFrom(
          backgroundColor: isOwner ? Colors.grey : const Color(0xFFE64A19),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
