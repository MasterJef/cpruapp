import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class PostJobForm extends StatefulWidget {
  const PostJobForm({super.key});

  @override
  State<PostJobForm> createState() => _PostJobFormState();
}

class _PostJobFormState extends State<PostJobForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers สำหรับดึงค่าจาก TextField
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = 'General'; // ค่าเริ่มต้น Dropdown
  bool _isLoading = false; // ตัวแปรเช็คสถานะโหลด

  // ฟังก์ชันบันทึกข้อมูล
  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // เริ่มหมุนติ้วๆ
      });

      try {
        // เตรียมข้อมูลที่จะบันทึก
        // เนื่องจากยังไม่มีระบบอัปโหลดรูป ผมจะสุ่มรูปให้ตามหมวดหมู่เพื่อความสวยงาม
        String randomImage = _selectedCategory == 'Food'
            ? 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=600'
            : 'https://images.pexels.com/photos/4491461/pexels-photo-4491461.jpeg?auto=compress&cs=tinysrgb&w=600';

        await FirebaseFirestore.instance.collection('jobs').add({
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'price': int.parse(_priceController.text.trim()), // แปลงเป็นตัวเลข
          'location': _locationController.text.trim(),
          'category': _selectedCategory,
          'imageUrl': randomImage,
          'created_at': FieldValue.serverTimestamp(),
          'createdBy':
              FirebaseAuth.instance.currentUser!.uid, // เวลาปัจจุบันของ Server
        });

        // บันทึกเสร็จแล้ว
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('โพสต์งานเรียบร้อยแล้ว!')),
          );
          Navigator.pop(context); // ปิดหน้าฟอร์ม
        }
      } catch (e) {
        // กรณีเกิด Error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // หยุดหมุน
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงประกาศงานใหม่')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. ชื่องาน
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่องาน (เช่น ฝากซื้อข้าว, ขนของ)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'กรุณากรอกชื่องาน' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. หมวดหมู่ (Dropdown)
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'หมวดหมู่',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ['Food', 'General', 'Delivery', 'Tutoring']
                          .map(
                            (label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val!),
                    ),
                    const SizedBox(height: 16),

                    // 3. ราคา
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ค่าจ้าง (บาท)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'บาท',
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'กรุณาระบุราคา';
                        if (int.tryParse(val) == null)
                          return 'กรอกเป็นตัวเลขเท่านั้น';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. สถานที่
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'สถานที่ (เช่น หอพักชาย 3)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'กรุณาระบุสถานที่' : null,
                    ),
                    const SizedBox(height: 16),

                    // 5. รายละเอียด
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดงานเพิ่มเติม',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'กรุณากรอกรายละเอียด' : null,
                    ),
                    const SizedBox(height: 30),

                    // ปุ่มกดโพสต์
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _submitJob,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'โพสต์งาน (Post Job)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
