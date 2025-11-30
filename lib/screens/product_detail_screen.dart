import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../widgets/full_screen_image.dart';
import 'post_product_screen.dart';
// import 'chat_room_screen.dart';

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
      if (mounted) {
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
          extendBodyBehindAppBar: !isDesktop,
          appBar: AppBar(
            backgroundColor: isDesktop ? Colors.white : Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDesktop ? Colors.black : Colors.white,
            ),
            title: isDesktop
                ? const Text(
                    'รายละเอียดสินค้า',
                    style: TextStyle(color: Colors.black),
                  )
                : null,
            actions: [
              if (isOwner) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PostProductScreen(product: widget.product),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteProduct(context),
                  ),
                ),
              ],
            ],
          ),
          body: isDesktop
              ? _buildDesktopLayout(context, isOwner)
              : _buildMobileLayout(context, isOwner),

          bottomNavigationBar: isDesktop
              ? null
              : _buildBottomActionBar(context, isOwner),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isOwner) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black,
            child: _buildImageGallery(isDesktop: true),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 30,
                  ),
                  child: _buildContent(context),
                ),
              ),
              _buildBottomActionBar(context, isOwner, isDesktop: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isOwner) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildImageGallery(isDesktop: false),
          Container(
            transform: Matrix4.translationValues(0.0, -20.0, 0.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery({required bool isDesktop}) {
    final double height = isDesktop
        ? double.infinity
        : MediaQuery.of(context).size.height * 0.45;

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: PageView.builder(
            itemCount: widget.product.imageUrls.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(
                        imageUrls: widget.product.imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  widget.product.imageUrls[index],
                  fit: isDesktop ? BoxFit.contain : BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: isDesktop ? 20 : MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: IconButton(
            onPressed: () {
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
            icon: const Icon(Icons.fullscreen, color: Colors.white, size: 30),
            style: IconButton.styleFrom(backgroundColor: Colors.black45),
          ),
        ),
        if (widget.product.imageUrls.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.product.imageUrls.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? const Color(0xFFE64A19)
                        : Colors.white54,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            Chip(
              label: Text(widget.product.condition),
              backgroundColor: Colors.grey[100],
            ),
            Chip(
              label: Text(widget.product.category),
              backgroundColor: Colors.grey[100],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.product.price.toStringAsFixed(0)} บาท',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE64A19),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(widget.product.authorAvatar),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'ดูร้านค้า',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    bool isOwner, {
    bool isDesktop = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: isDesktop
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: isOwner ? null : () {},
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('ทักแชท'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE64A19)),
                foregroundColor: const Color(0xFFE64A19),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isOwner ? null : () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE64A19),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isOwner ? 'สินค้าของคุณ' : 'ซื้อทันที',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
