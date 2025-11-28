// lib/screens/post_product_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

class PostProductScreen extends StatefulWidget {
  const PostProductScreen({super.key});

  @override
  State<PostProductScreen> createState() => _PostProductScreenState();
}

class _PostProductScreenState extends State<PostProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ImageService _imageService = ImageService();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedCategory = 'ของใช้';
  final List<String> _categories = [
    'เสื้อผ้า',
    'หนังสือ',
    'อุปกรณ์ไอที',
    'ของใช้',
    'อื่นๆ',
  ];

  String _selectedCondition = 'มือสอง';
  final List<String> _conditions = ['มือหนึ่ง', 'มือสอง'];

  XFile? _imageFile;

  Future<void> _pickImage() async {
    final XFile? file = await _imageService.pickImage();
    if (file != null) setState(() => _imageFile = file);
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาใส่รูปสินค้า')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. อัปโหลดรูป
      String? imageUrl = await _imageService.uploadImage(
        _imageFile!,
        'market_products',
      );
      imageUrl ??= 'https://via.placeholder.com/300';

      // 2. บันทึก Firestore
      await FirebaseFirestore.instance.collection('market_items').add({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'imageUrl': imageUrl,
        'sellerId': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'available',
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลงขายสินค้าเรียบร้อย!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลงขายสินค้า'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // เลือกรูป
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageFile != null
                            ? (kIsWeb
                                  ? Image.network(
                                      _imageFile!.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_imageFile!.path),
                                      fit: BoxFit.cover,
                                    ))
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  Text('เพิ่มรูปสินค้า'),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อสินค้า',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'ระบุชื่อสินค้า' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'ราคา (บาท)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'ระบุราคา' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField(
                            value: _selectedCondition,
                            decoration: const InputDecoration(
                              labelText: 'สภาพ',
                              border: OutlineInputBorder(),
                            ),
                            items: _conditions
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCondition = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'หมวดหมู่',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียด',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'ระบุรายละเอียด' : null,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _submitProduct,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'ลงขายทันที',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
