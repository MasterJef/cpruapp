import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/job_model.dart';
import '../models/user_model.dart';
import '../services/image_service.dart';

class PostJobScreen extends StatefulWidget {
  final Job? job;
  const PostJobScreen({super.key, this.job});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ImageService _imageService = ImageService();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String? _selectedCategory;
  // ปรับหมวดหมู่ตาม Request
  final List<String> _categories = [
    'อาหาร',
    'ขนของ',
    'ติวหนังสือ',
    'ทำความสะอาด',
    'ทั่วไป',
  ];

  List<String> _existingUrls = [];
  List<XFile> _newFiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _titleCtrl.text = widget.job!.title;
      _descCtrl.text = widget.job!.description;
      _priceCtrl.text = widget.job!.price.replaceAll(RegExp(r'[^0-9]'), '');
      _locationCtrl.text = widget.job!.location;
      _existingUrls = List.from(widget.job!.imageUrls);
      // เช็คว่าหมวดหมู่เดิมอยู่ใน List ใหม่ไหม ถ้าไม่อยู่ให้เป็น 'ทั่วไป'
      _selectedCategory = _categories.contains(widget.job!.id)
          ? widget.job!.id
          : null;
      // *หมายเหตุ: Job Model ไม่ได้เก็บ category field ไว้ในตัวอย่างก่อนหน้า
      // แต่ถ้ามีการเก็บให้ดึงมาใส่ตรงนี้
    }
  }

  Future<void> _pickImages() async {
    List<XFile> files = await _imageService.pickMultiImages();
    if (files.isNotEmpty) setState(() => _newFiles.addAll(files));
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
      return;
    }
    if (_existingUrls.isEmpty && _newFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเพิ่มรูปภาพ')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      List<String> newUrls = await _imageService.uploadMultipleImages(
        _newFiles,
        'job_images',
      );
      List<String> finalUrls = [..._existingUrls, ...newUrls];

      Map<String, dynamic> data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': _priceCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'category': _selectedCategory, // บันทึก Category
        'imageUrls': finalUrls,
        'authorName': '${currentUser.firstName} ${currentUser.lastName}',
        'authorAvatar': currentUser.imageUrl,
      };

      if (widget.job == null) {
        await FirebaseFirestore.instance.collection('jobs').add({
          ...data,
          'type': 'job',
          'status': 'open',
          'created_at': FieldValue.serverTimestamp(),
          'createdBy': user.uid,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.job!.id)
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
        title: Text(widget.job == null ? 'โพสต์งานใหม่' : 'แก้ไขประกาศงาน'),
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
                    // Image Preview Area
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
                      controller: _titleCtrl,
                      decoration: _inputDecoration('ชื่องาน', Icons.work),
                      validator: (v) => v!.isEmpty ? 'ระบุชื่อ' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField(
                      value: _selectedCategory,
                      decoration: _inputDecoration('หมวดหมู่', Icons.category),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'ราคา',
                              Icons.attach_money,
                            ),
                            validator: (v) => v!.isEmpty ? 'ระบุราคา' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _locationCtrl,
                            decoration: _inputDecoration(
                              'สถานที่',
                              Icons.location_on,
                            ),
                            validator: (v) => v!.isEmpty ? 'ระบุสถานที่' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'รายละเอียด',
                        Icons.description,
                      ),
                      validator: (v) => v!.isEmpty ? 'ระบุรายละเอียด' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _saveJob,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text(
                          widget.job == null ? 'โพสต์งาน' : 'บันทึก',
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
