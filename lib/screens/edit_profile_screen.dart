// lib/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ต้องมี package นี้
import '../models/user_model.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ... (Controllers เดิม) ...
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _facultyCtrl;
  late TextEditingController _majorCtrl;
  late TextEditingController _yearCtrl;

  final _authService = AuthService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // (เหมือนเดิม)
    _firstNameCtrl = TextEditingController(text: currentUser.firstName);
    _lastNameCtrl = TextEditingController(text: currentUser.lastName);
    _idCtrl = TextEditingController(text: currentUser.studentId);
    _facultyCtrl = TextEditingController(text: currentUser.faculty);
    _majorCtrl = TextEditingController(text: currentUser.major);
    _yearCtrl = TextEditingController(text: currentUser.year);
  }

  // ฟังก์ชันเลือกและอัปโหลดรูป
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    // เลือกรูปจาก Gallery
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _isUploading = true);

      // เรียก Service อัปโหลด
      String? newUrl = await _authService.uploadProfileImage(File(image.path));

      setState(() => _isUploading = false);

      if (newUrl != null) {
        setState(() {}); // Refresh UI เพื่อโชว์รูปใหม่
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตรูปโปรไฟล์สำเร็จ!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปโหลดล้มเหลว'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // (ส่วน _saveProfile ใช้โค้ดเดิมได้ แต่ควรเพิ่ม logic update firestore ด้วย ถ้าต้องการสมบูรณ์)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขข้อมูลส่วนตัว')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ส่วนรูปภาพ
              Center(
                child: Stack(
                  children: [
                    // ถ้ากำลังอัปโหลด ให้โชว์ Loading ทับ
                    _isUploading
                        ? const CircleAvatar(
                            radius: 50,
                            child: CircularProgressIndicator(),
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(currentUser.imageUrl),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.orange,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: _pickAndUploadImage, // เรียกฟังก์ชัน
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ... (ส่วน TextFields เหมือนเดิม) ...
              const SizedBox(height: 24),
              // ...
              // ปุ่มบันทึก ...
            ],
          ),
        ),
      ),
    );
  }
}
