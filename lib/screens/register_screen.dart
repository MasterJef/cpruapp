// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../main.dart'; // import เพื่อไปหน้าหลัก

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      // จำลองการสมัครสำเร็จ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')));

      // ไปหน้าหลักทันที (เข้าสู่ระบบอัตโนมัติ)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
        (route) => false, // ลบประวัติหน้าเก่าออกให้หมด
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // สีปุ่ม Back เป็นสีดำ
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'สร้างบัญชีใหม่',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'กรอกข้อมูลเพื่อเริ่มใช้งาน UniJobs',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // ชื่อ-นามสกุล
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ชื่อ - นามสกุล',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกชื่อ' : null,
              ),
              const SizedBox(height: 16),

              // อีเมล
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'อีเมล / รหัสนักศึกษา',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกอีเมล' : null,
              ),
              const SizedBox(height: 16),

              // รหัสผ่าน
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'รหัสผ่าน',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val!.length < 6) ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว' : null,
              ),
              const SizedBox(height: 16),

              // ยืนยันรหัสผ่าน
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'ยืนยันรหัสผ่าน',
                  prefixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val != _passController.text) return 'รหัสผ่านไม่ตรงกัน';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // ปุ่มสมัคร
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _register,
                  style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text(
                    'ลงทะเบียน',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
