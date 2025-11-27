// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // Import Service

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService(); // เรียกใช้ Service
  bool _isLoading = false;

  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // เรียกฟังก์ชันสมัครสมาชิกจาก AuthService
      String? error = await _authService.register(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        studentId: _idCtrl.text.trim(),
        faculty: _facultyCtrl.text.trim(),
        major: _majorCtrl.text.trim(),
        year: _yearCtrl.text.trim(),
      );

      setState(() => _isLoading = false);

      if (error == null) {
        // สำเร็จ -> ไปหน้าหลัก
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        // ไม่สำเร็จ -> แจ้งเตือน
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'สร้างบัญชีใหม่',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ข้อมูลส่วนตัว
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _firstNameCtrl,
                            'ชื่อ',
                            Icons.person,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            _lastNameCtrl,
                            'นามสกุล',
                            Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _idCtrl,
                      'รหัสนักศึกษา',
                      Icons.badge,
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_facultyCtrl, 'คณะ', Icons.school),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            _majorCtrl,
                            'สาขา',
                            Icons.book,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // ข้อมูลบัญชี
                    _buildTextField(_emailCtrl, 'อีเมล', Icons.email),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'รหัสผ่าน',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.length < 6 ? 'รหัสผ่านต้องมี 6 ตัวขึ้นไป' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'ยืนยันรหัสผ่าน',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v != _passCtrl.text ? 'รหัสผ่านไม่ตรงกัน' : null,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          'ลงทะเบียน',
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

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v!.isEmpty ? 'ระบุ$label' : null,
    );
  }
}
