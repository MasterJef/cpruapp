// lib/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart'; // Import Model
import '../services/image_service.dart'; // Import Service

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ImageService _imageService = ImageService();

  // Controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _studentIdCtrl;
  late TextEditingController _facultyCtrl;
  late TextEditingController _majorCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _lineIdCtrl;

  XFile? _newImageFile; // รูปใหม่ที่เลือก

  @override
  void initState() {
    super.initState();
    // ดึงค่าจาก Global currentUser มาใส่เป็นค่าเริ่มต้น
    _firstNameCtrl = TextEditingController(text: currentUser.firstName);
    _lastNameCtrl = TextEditingController(text: currentUser.lastName);
    _studentIdCtrl = TextEditingController(text: currentUser.studentId);
    _facultyCtrl = TextEditingController(text: currentUser.faculty);
    _majorCtrl = TextEditingController(text: currentUser.major);
    _yearCtrl = TextEditingController(text: currentUser.year);
    _phoneCtrl = TextEditingController(text: currentUser.phone ?? '');
    _lineIdCtrl = TextEditingController(text: currentUser.lineId ?? '');

    // (Optional) ถ้าอยากชัวร์จริงๆ ควรดึงจาก Firestore อีกรอบตรงนี้ก็ได้
    // แต่เพื่อความเร็ว ใช้ currentUser ไปก่อนครับ
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _studentIdCtrl.dispose();
    _facultyCtrl.dispose();
    _majorCtrl.dispose();
    _yearCtrl.dispose();
    _phoneCtrl.dispose();
    _lineIdCtrl.dispose();
    super.dispose();
  }

  // เลือกรูป
  Future<void> _pickImage() async {
    final XFile? image = await _imageService.pickImage();
    if (image != null) {
      setState(() {
        _newImageFile = image;
      });
    }
  }

  // บันทึกข้อมูล
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String imageUrl = currentUser.imageUrl;

      // 1. ถ้ามีการเปลี่ยนรูป ให้อัปโหลดใหม่
      if (_newImageFile != null) {
        String? url = await _imageService.uploadImage(
          _newImageFile!,
          'user_profiles/${user.uid}',
        );
        if (url != null) {
          imageUrl = url;
        }
      }

      // 2. เตรียมข้อมูลสำหรับ Update
      Map<String, dynamic> dataToUpdate = {
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'studentId': _studentIdCtrl.text.trim(),
        'faculty': _facultyCtrl.text.trim(),
        'major': _majorCtrl.text.trim(),
        'year': _yearCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'lineId': _lineIdCtrl.text.trim(),
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 3. Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(dataToUpdate);

      // 4. Update Global Variable (เพื่อให้หน้าอื่นเห็นความเปลี่ยนแปลงทันที)
      setState(() {
        currentUser.firstName = dataToUpdate['firstName'];
        currentUser.lastName = dataToUpdate['lastName'];
        currentUser.studentId = dataToUpdate['studentId'];
        currentUser.faculty = dataToUpdate['faculty'];
        currentUser.major = dataToUpdate['major'];
        currentUser.year = dataToUpdate['year'];
        currentUser.phone = dataToUpdate['phone'];
        currentUser.lineId = dataToUpdate['lineId'];
        currentUser.imageUrl = imageUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')));
        Navigator.pop(context); // กลับไปหน้า Profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
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
                    // --- ส่วนรูปโปรไฟล์ ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _getProfileImage(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- ฟอร์มข้อมูล ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _firstNameCtrl,
                            'ชื่อ',
                            Icons.person,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            _lastNameCtrl,
                            'นามสกุล',
                            Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _studentIdCtrl,
                      'รหัสนักศึกษา',
                      Icons.badge,
                      isNumber: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_facultyCtrl, 'คณะ', Icons.school),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            _majorCtrl,
                            'สาขาวิชา',
                            Icons.book,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            _yearCtrl,
                            'ชั้นปี',
                            Icons.calendar_today,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _phoneCtrl,
                      'เบอร์โทรศัพท์',
                      Icons.phone,
                      isNumber: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_lineIdCtrl, 'Line ID', Icons.chat),

                    const SizedBox(height: 40),

                    // --- ปุ่มบันทึก ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'บันทึกการเปลี่ยนแปลง',
                          style: TextStyle(fontSize: 18),
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

  // Helper เลือกแสดงรูป (File vs Network)
  ImageProvider _getProfileImage() {
    if (_newImageFile != null) {
      if (kIsWeb) {
        return NetworkImage(_newImageFile!.path); // Web ใช้ path blob
      } else {
        return FileImage(File(_newImageFile!.path)); // Mobile ใช้ File
      }
    }
    return NetworkImage(currentUser.imageUrl); // รูปเดิม
  }

  // Helper สร้าง TextField
  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (val) => val == null || val.isEmpty ? 'กรุณาระบุ$label' : null,
    );
  }
}
