// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _facultyCtrl;
  late TextEditingController _majorCtrl;
  late TextEditingController _yearCtrl;

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลปัจจุบันมาใส่ในช่องกรอก
    _firstNameCtrl = TextEditingController(text: currentUser.firstName);
    _lastNameCtrl = TextEditingController(text: currentUser.lastName);
    _idCtrl = TextEditingController(text: currentUser.studentId);
    _facultyCtrl = TextEditingController(text: currentUser.faculty);
    _majorCtrl = TextEditingController(text: currentUser.major);
    _yearCtrl = TextEditingController(text: currentUser.year);
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // อัปเดตข้อมูล Global
        currentUser.firstName = _firstNameCtrl.text;
        currentUser.lastName = _lastNameCtrl.text;
        currentUser.studentId = _idCtrl.text;
        currentUser.faculty = _facultyCtrl.text;
        currentUser.major = _majorCtrl.text;
        currentUser.year = _yearCtrl.text;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย!')));

      // ส่งค่า true กลับไปเพื่อบอกให้หน้าก่อนหน้า refresh
      Navigator.pop(context, true);
    }
  }

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
              // รูปโปรไฟล์ (จำลองการเปลี่ยนรูป)
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ฟีเจอร์อัปโหลดรูป (จำลอง)'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildTextField(_firstNameCtrl, 'ชื่อ')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_lastNameCtrl, 'นามสกุล')),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _idCtrl,
                'รหัสนักศึกษา',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(_facultyCtrl, 'คณะ'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(_majorCtrl, 'สาขาวิชา'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      _yearCtrl,
                      'ชั้นปี',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    'บันทึกการเปลี่ยนแปลง',
                    style: TextStyle(fontSize: 18),
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
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      validator: (val) => val!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
    );
  }
}
