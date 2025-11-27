// lib/screens/post_job_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/job_model.dart'; // Import Model
import '../services/image_service.dart'; // Import Service ที่เพิ่งสร้าง

class PostJobScreen extends StatefulWidget {
  final Job? job; // ถ้ามีค่าส่งมา = โหมดแก้ไข, ถ้า null = โหมดสร้างใหม่

  const PostJobScreen({super.key, this.job});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  // Variables
  String? _selectedCategory;
  final List<String> _categories = ['อาหาร', 'ขนของ', 'ติวหนังสือ', 'ทั่วไป'];

  File? _imageFile; // รูปใหม่ที่เพิ่งเลือกจากเครื่อง
  String? _existingImageUrl; // รูปเดิม (กรณีแก้ไข)

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นโหมดแก้ไข ให้ดึงข้อมูลเก่ามาใส่ Form
    if (widget.job != null) {
      _titleController.text = widget.job!.title;
      _descController.text = widget.job!.description;
      // ดึงตัวเลขออกจาก string เช่น "100 บาท" -> "100"
      _priceController.text = widget.job!.price.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      _locationController.text = widget.job!.location;
      _existingImageUrl = widget.job!.imageUrl;

      // เช็คว่า Category เดิมมีอยู่ใน list หรือไม่ (กัน Error)
      // (Logic นี้สมมติว่าไม่ได้เก็บ Category ใน Job Model แต่ถ้ามีต้องดึงมาใส่ด้วย)
      // _selectedCategory = widget.job!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ฟังก์ชันเลือกรูป
  Future<void> _pickImage() async {
    File? file = await ImageService.pickImage();
    if (file != null) {
      setState(() {
        _imageFile = file;
      });
    }
  }

  // ฟังก์ชันบันทึก (Add หรือ Update)
  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
      return;
    }

    // กรณีสร้างใหม่ ต้องมีรูป (หรือจะอนุโลมก็ได้แล้วแต่ requirement)
    if (widget.job == null && _imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเพิ่มรูปภาพประกอบ')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. จัดการรูปภาพ
      String imageUrl =
          _existingImageUrl ?? 'https://via.placeholder.com/300'; // Default

      // ถ้ามีการเลือกรูปใหม่ ให้อัปโหลด
      if (_imageFile != null) {
        String? uploadedUrl = await ImageService.uploadImage(
          _imageFile!,
          'job_images',
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final jobData = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': '${_priceController.text.trim()} บาท',
        'location': _locationController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': imageUrl,
        'type': 'job',
      };

      if (widget.job == null) {
        // --- CREATE MODE ---
        await FirebaseFirestore.instance.collection('jobs').add({
          ...jobData,
          'status': 'open',
          'created_at': FieldValue.serverTimestamp(),
          'createdBy': user.uid,
        });
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('โพสต์งานสำเร็จ!')));
      } else {
        // --- EDIT MODE ---
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.job!.id)
            .update({
              ...jobData,
              'updated_at':
                  FieldValue.serverTimestamp(), // Optional: เก็บเวลาแก้ไข
            });
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('แก้ไขงานสำเร็จ!')));
      }

      if (mounted) Navigator.pop(context); // ปิดหน้าจอ
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.job != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'แก้ไขประกาศงาน' : 'โพสต์งานใหม่'),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- ส่วนเลือกรูปภาพ ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : (_existingImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_existingImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child: (_imageFile == null && _existingImageUrl == null)
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'แตะเพื่อเพิ่มรูปภาพ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(_titleController, 'ชื่องาน', Icons.title),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration('หมวดหมู่', Icons.category),
                      value: _selectedCategory,
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            _priceController,
                            'ค่าจ้าง (บาท)',
                            Icons.attach_money,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            _locationController,
                            'สถานที่',
                            Icons.location_on,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _descController,
                      'รายละเอียด',
                      Icons.description,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _saveJob,
                        icon: Icon(isEditMode ? Icons.save : Icons.send),
                        label: Text(
                          isEditMode ? 'บันทึกการแก้ไข' : 'โพสต์ประกาศงาน',
                          style: const TextStyle(fontSize: 18),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      validator: (val) => val == null || val.isEmpty ? 'กรุณาระบุ$label' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
