// lib/screens/post_job_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers สำหรับรับค่าจากฟอร์ม
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // ตัวแปรสำหรับ Dropdown
  String? _selectedCategory;
  final List<String> _categories = ['อาหาร', 'ขนของ', 'ติวหนังสือ', 'ทั่วไป'];

  @override
  void dispose() {
    // คืน memory เมื่อปิดหน้านี้
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ฟังก์ชันบันทึกข้อมูลลง Firestore
  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      // 1. ตรวจสอบว่าเลือกหมวดหมู่หรือยัง
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกหมวดหมู่งาน')));
        return;
      }

      // 2. ตรวจสอบ User ปัจจุบัน
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด: ไม่พบข้อมูลผู้ใช้')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // 3. เตรียมข้อมูล
        // ใช้รูป Mock ตามที่ขอ (ในอนาคตค่อยเปลี่ยนเป็นระบบอัปโหลดรูป)
        String mockImage =
            'https://cdn-icons-png.flaticon.com/512/3081/3081559.png';

        // 4. บันทึกลง Firestore
        await FirebaseFirestore.instance.collection('jobs').add({
          'title': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'price':
              '${_priceController.text.trim()} บาท', // เก็บเป็น String พร้อมหน่วย
          'location': _locationController.text.trim(),
          'category': _selectedCategory,
          'imageUrl': mockImage,
          'type': 'job', // ระบุประเภทว่าเป็นงานจ้าง
          'created_at': FieldValue.serverTimestamp(), // เวลาจาก Server
          'createdBy': user.uid, // เก็บ UID คนโพสต์เพื่อดึงประวัติได้
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('โพสต์งานเรียบร้อยแล้ว!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // ปิดหน้าจอ
        }
      } catch (e) {
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
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector เพื่อให้กดพื้นที่ว่างแล้วคีย์บอร์ดหุบลง
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('โพสต์งานใหม่'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'รายละเอียดงาน',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. ชื่องาน
                      _buildTextField(
                        controller: _titleController,
                        label: 'ชื่องาน',
                        hint: 'เช่น ฝากซื้อข้าว, หาคนช่วยขนของ',
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 16),

                      // 2. หมวดหมู่ (Dropdown)
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(
                          'หมวดหมู่',
                          Icons.category,
                        ),
                        value: _selectedCategory,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. ค่าจ้าง และ สถานที่ (วางคู่กัน)
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'ค่าจ้าง (บาท)',
                              hint: 'เช่น 100',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              controller: _locationController,
                              label: 'สถานที่',
                              hint: 'เช่น หอ 3, โรงอาหาร',
                              icon: Icons.location_on,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. รายละเอียด (Multiline)
                      _buildTextField(
                        controller: _descController,
                        label: 'รายละเอียดเพิ่มเติม',
                        hint: 'ระบุรายละเอียดให้ครบถ้วน...',
                        icon: Icons.description,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 30),

                      // ปุ่มโพสต์
                      SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _submitPost,
                          icon: const Icon(Icons.send),
                          label: const Text(
                            'โพสต์ประกาศงาน',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Widget Helper สำหรับสร้าง TextField สวยๆ ลดโค้ดซ้ำ
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon, hint: hint),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'กรุณาระบุ$label';
        }
        return null;
      },
    );
  }

  // Style Decoration ที่ใช้ร่วมกัน
  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
