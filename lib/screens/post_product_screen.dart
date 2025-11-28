import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/image_service.dart';

class PostProductScreen extends StatefulWidget {
  final Product? product;
  const PostProductScreen({super.key, this.product});

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

  List<String> _existingUrls = [];
  List<XFile> _newFiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toStringAsFixed(0);
      _selectedCategory = widget.product!.category;
      _selectedCondition = widget.product!.condition;
      _existingUrls = List.from(widget.product!.imageUrls);
    }
  }

  Future<void> _pickImages() async {
    List<XFile> files = await _imageService.pickMultiImages();
    if (files.isNotEmpty) setState(() => _newFiles.addAll(files));
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingUrls.isEmpty && _newFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเพิ่มรูปสินค้า')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      List<String> newUrls = await _imageService.uploadMultipleImages(
        _newFiles,
        'market_products',
      );
      List<String> finalUrls = [..._existingUrls, ...newUrls];

      Map<String, dynamic> data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'imageUrls': finalUrls,
        'authorName': '${currentUser.firstName} ${currentUser.lastName}',
        'authorAvatar': currentUser.imageUrl,
      };

      if (widget.product == null) {
        await FirebaseFirestore.instance.collection('market_items').add({
          ...data,
          'sellerId': user.uid,
          'status': 'available',
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('market_items')
            .doc(widget.product!.id)
            .update({...data, 'updated_at': FieldValue.serverTimestamp()});
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
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
        title: Text(widget.product == null ? 'ลงขายสินค้า' : 'แก้ไขสินค้า'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ..._existingUrls.map(
                            (url) => _buildPreview(url, true),
                          ),
                          ..._newFiles.map(
                            (file) => _buildPreview(file.path, kIsWeb),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อสินค้า',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'ระบุชื่อ' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'ราคา',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'ระบุราคา' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
                        child: Text(
                          widget.product == null ? 'ลงขาย' : 'บันทึก',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreview(String path, bool isNet) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: isNet
              ? NetworkImage(path)
              : FileImage(File(path)) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
