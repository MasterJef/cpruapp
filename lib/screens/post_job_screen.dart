// lib/screens/post_job_screen.dart
import 'dart:io'; // ใช้สำหรับ Mobile เท่านั้น
import 'package:flutter/foundation.dart'; // ใช้สำหรับ kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // ใช้ XFile

import '../models/job_model.dart';
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
  final ImageService _imageService = ImageService(); // Instance

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  // Variables
  String? _selectedCategory;
  final List<String> _categories = ['อาหาร', 'ขนของ', 'ติวหนังสือ', 'ทั่วไป'];

  // ใช้ XFile แทน File เพื่อรองรับ Web
  XFile? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _titleController.text = widget.job!.title;
      _descController.text = widget.job!.description;
      _priceController.text = widget.job!.price.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      _locationController.text = widget.job!.location;
      _existingImageUrl = widget.job!.imageUrl;
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
    final XFile? file = await _imageService.pickImage();
    if (file != null) {
      setState(() {
        _imageFile = file;
      });
    }
  }

  // ฟังก์ชันบันทึก
  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่')));
      return;
    }
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

      String imageUrl = _existingImageUrl ?? 'https://via.placeholder.com/300';

      // ถ้ามีรูปใหม่ ส่ง XFile ไปอัปโหลด
      if (_imageFile != null) {
        String? uploadedUrl = await _imageService.uploadImage(
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
        // Create
        await FirebaseFirestore.instance.collection('jobs').add({
          ...jobData,
          'status': 'open',
          'created_at': FieldValue.serverTimestamp(),
          'createdBy': user.uid,
          'acceptedBy': null,
        });
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('โพสต์งานสำเร็จ!')));
      } else {
        // Update
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.job!.id)
            .update({...jobData, 'updated_at': FieldValue.serverTimestamp()});
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('แก้ไขงานสำเร็จ!')));
      }

      if (mounted) Navigator.pop(context);
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
                    // --- Image Preview Area ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            _buildImagePreview(), // แยก Widget ออกมาเพื่อจัดการ Logic Web/Mobile
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

  // --- Widget จัดการ Preview รูป (แก้ปัญหา Platform Error) ---
  Widget _buildImagePreview() {
    // 1. กรณีเลือกรูปใหม่มาแล้ว
    if (_imageFile != null) {
      if (kIsWeb) {
        // บน Web: Image.network อ่านจาก path (Blob URL)
        return Image.network(
          _imageFile!.path,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } else {
        // บน Mobile: Image.file อ่านจาก path (File System)
        return Image.file(
          File(_imageFile!.path),
          fit: BoxFit.cover,
          width: double.infinity,
        );
      }
    }
    // 2. กรณีมีรูปเดิม (Edit Mode)
    else if (_existingImageUrl != null) {
      return Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    // 3. ยังไม่มีรูป
    else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('แตะเพื่อเพิ่มรูปภาพ', style: TextStyle(color: Colors.grey)),
        ],
      );
    }
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
