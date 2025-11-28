import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import 'post_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isOwner = FirebaseAuth.instance.currentUser?.uid == product.sellerId;

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
                  builder: (_) => PostProductScreen(product: product),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: product.imageUrls.length,
                itemBuilder: (context, index) =>
                    Image.network(product.imageUrls[index], fit: BoxFit.cover),
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
                        backgroundImage: NetworkImage(product.authorAvatar),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        product.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${product.price.toStringAsFixed(0)} บาท',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text(product.condition)),
                  const Divider(height: 30),
                  const Text(
                    'รายละเอียด',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(product.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
