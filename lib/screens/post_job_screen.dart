import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/job_model.dart';
import '../models/user_model.dart'; // เพื่อเอาชื่อ/รูป currentUser
import '../services/image_service.dart';

class PostJobScreen extends StatefulWidget {
  final Job? job; // รับ Job เข้ามาเพื่อแก้ไข
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
  final List<String> _categories = ['อาหาร', 'ขนของ', 'ติวหนังสือ', 'ทั่วไป'];

  // จัดการรูปภาพ
  List<String> _existingUrls = []; // รูปเดิมที่มีอยู่
  List<XFile> _newFiles = []; // รูปใหม่ที่เพิ่งเลือก

  @override
  void initState() {
    super.initState();
    // Edit Mode Setup
    if (widget.job != null) {
      _titleCtrl.text = widget.job!.title;
      _descCtrl.text = widget.job!.description;
      _priceCtrl.text = widget.job!.price.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      ); // เอาแค่ตัวเลข
      _locationCtrl.text = widget.job!.location;
      _existingUrls = List.from(widget.job!.imageUrls);
      // _selectedCategory logic (ถ้ามีเก็บใน db)
    }
  }

  Future<void> _pickImages() async {
    List<XFile> files = await _imageService.pickMultiImages();
    if (files.isNotEmpty) {
      setState(() {
        _newFiles.addAll(files);
      });
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
      return;
    }
    // เช็คว่ามีรูปบ้างไหม (ทั้งเก่าและใหม่)
    if (_existingUrls.isEmpty && _newFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเพิ่มรูปภาพอย่างน้อย 1 รูป')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. อัปโหลดรูปใหม่
      List<String> newUrls = await _imageService.uploadMultipleImages(
        _newFiles,
        'job_images',
      );

      // 2. รวมรููปทั้งหมด
      List<String> finalImageUrls = [..._existingUrls, ...newUrls];

      // 3. เตรียมข้อมูล
      Map<String, dynamic> data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': _priceCtrl.text.trim(), // เก็บแค่ตัวเลข
        'location': _locationCtrl.text.trim(),
        'category': _selectedCategory,
        'imageUrls': finalImageUrls,
        'authorName':
            '${currentUser.firstName} ${currentUser.lastName}', // Denormalization
        'authorAvatar': currentUser.imageUrl,
      };

      if (widget.job == null) {
        // Create
        await FirebaseFirestore.instance.collection('jobs').add({
          ...data,
          'type': 'job',
          'status': 'open',
          'created_at': FieldValue.serverTimestamp(),
          'createdBy': user.uid,
        });
      } else {
        // Update
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
                    // Image Preview Area (Horizontal Scroll)
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // ปุ่มเพิ่มรูป
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
                          // รูปเดิม
                          ..._existingUrls.map(
                            (url) => _buildPreviewItem(url, isNetwork: true),
                          ),
                          // รูปใหม่
                          ..._newFiles.map(
                            (file) =>
                                _buildPreviewItem(file.path, isNetwork: kIsWeb),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_titleCtrl, 'ชื่องาน', Icons.work),
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
                          child: _buildTextField(
                            _priceCtrl,
                            'ราคา (บาท)',
                            Icons.attach_money,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            _locationCtrl,
                            'สถานที่',
                            Icons.location_on,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _descCtrl,
                      'รายละเอียด',
                      Icons.description,
                      maxLines: 5,
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
                          widget.job == null ? 'โพสต์งาน' : 'บันทึกการแก้ไข',
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

  Widget _buildPreviewItem(String path, {required bool isNetwork}) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: isNetwork
              ? NetworkImage(path)
              : FileImage(File(path)) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      // สามารถเพิ่มปุ่มลบรูปตรงนี้ได้ในอนาคต
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: (v) => v!.isEmpty ? 'ระบุ$label' : null,
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
