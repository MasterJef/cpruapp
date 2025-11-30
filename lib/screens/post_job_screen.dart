import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cprujobapp/services/image_service.dart';
import 'package:cprujobapp/models/job_model.dart'; // Import Model

class PostJobScreen extends StatefulWidget {
  final Job? job; // รับค่ามาเพื่อแก้ไข (ถ้ามี)
  const PostJobScreen({super.key, this.job});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ ประกาศ Controller ให้ครบทุกตัว (แก้ Error ตรงนี้)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // เพิ่มตัวนี้แล้ว

  String _selectedCategory = 'ทั่วไป';
  final List<String> _categories = [
    'อาหาร',
    'ขนของ',
    'ติวหนังสือ',
    'ทำความสะอาด',
    'ทั่วไป',
  ];

  // ระบบรูปภาพ (หลายรูป)
  List<XFile> _newImages = [];
  List<String> _existingImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นการ "แก้ไข" ให้ดึงข้อมูลเดิมมาใส่
    if (widget.job != null) {
      _titleController.text = widget.job!.title;
      _descController.text = widget.job!.description;
      _priceController.text = widget.job!.price;
      _locationController.text = widget.job!.location; // ใส่ข้อมูลเดิมลงช่อง

      if (_categories.contains(widget.job!.category)) {
        _selectedCategory = widget.job!.category;
      }

      // ดึงรูปเดิม
      _existingImages = List.from(widget.job!.imageUrls);
    }
  }

  @override
  void dispose() {
    // คืนหน่วยความจำเมื่อปิดหน้า
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // เลือกรูปหลายรูป
  Future<void> _pickImages() async {
    // ใช้ ImageService ที่เราอัปเกรดแล้ว
    final List<XFile> images = await ImageService().pickMultiImages();

    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImages.removeAt(index));
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    // ต้องมีรูปอย่างน้อย 1 รูป (รวมเก่าและใหม่)
    if (_newImages.isEmpty && _existingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่รูปภาพอย่างน้อย 1 รูป')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. อัปโหลดรูปใหม่ (ถ้ามี)
      List<String> newImageUrls = await ImageService().uploadMultipleImages(
        _newImages,
        'job_images',
      );

      // รวมรูปเก่า + รูปใหม่
      List<String> finalImages = [..._existingImages, ...newImageUrls];

      // เตรียมข้อมูล
      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': _priceController.text.trim(),
        'location': _locationController.text.trim(), // ส่งค่า location
        'category': _selectedCategory,
        'imageUrls': finalImages,
        // ใส่ imageUrl (String) ไว้ด้วยเผื่อโค้ดเก่าๆ ที่ยังเรียกใช้อยู่
        'imageUrl': finalImages.isNotEmpty ? finalImages.first : '',
      };

      if (widget.job != null) {
        // --- UPDATE ---
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.job!.id)
            .update(data);

        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('แก้ไขงานสำเร็จ!')));
      } else {
        // --- CREATE ---
        // ดึงข้อมูลผู้ใช้มาแปะ (Denormalization)
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() ?? {};

        data['status'] = 'open';
        data['createdBy'] = user.uid;
        data['createdAt'] = FieldValue.serverTimestamp();
        data['authorName'] = userData['firstName'] ?? 'Unknown';
        data['authorAvatar'] = userData['imageUrl'] ?? '';

        await FirebaseFirestore.instance.collection('jobs').add(data);

        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('โพสต์งานสำเร็จ!')));
      }

      if (mounted) {
        Navigator.pop(context);
        if (widget.job != null)
          Navigator.pop(context); // pop 2 ทีถ้ามาจากการแก้ไข
      }
    } catch (e) {
      print(e);
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
    bool isEditing = widget.job != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขประกาศงาน' : 'ลงประกาศงาน'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ส่วนแสดงรูปภาพ (Horizontal Scroll) ---
                    const Text(
                      'รูปภาพประกอบ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        children: [
                          // ปุ่มเพิ่มรูป
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey),
                                  Text(
                                    "เพิ่มรูป",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // รูปเดิม (Existing)
                          ..._existingImages.asMap().entries.map((entry) {
                            return _buildImagePreview(
                              entry.value,
                              true,
                              () => _removeExistingImage(entry.key),
                            );
                          }),
                          // รูปใหม่ (New)
                          ..._newImages.asMap().entries.map((entry) {
                            return _buildImagePreview(
                              entry.value.path,
                              kIsWeb,
                              () => _removeNewImage(entry.key),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่องาน (เช่น ฝากซื้อข้าว)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'ระบุชื่องาน' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'ค่าจ้าง (บาท)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'ระบุราคา' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField(
                            value: _selectedCategory,
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v!),
                            decoration: const InputDecoration(
                              labelText: 'หมวดหมู่',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ✅ ช่องกรอกสถานที่ (ใช้ _locationController ที่ประกาศแล้ว)
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'สถานที่ (เช่น หอใน, ตึกวิศวะ)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'ระบุสถานที่' : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดเพิ่มเติม',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'ระบุรายละเอียด' : null,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _submitJob,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: Text(
                          isEditing ? 'บันทึกการแก้ไข' : 'โพสต์งานเลย',
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

  Widget _buildImagePreview(String path, bool isNet, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            image: DecorationImage(
              image: isNet
                  ? NetworkImage(path)
                  : FileImage(File(path)) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
