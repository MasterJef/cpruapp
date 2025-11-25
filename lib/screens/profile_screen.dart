// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ฟังก์ชันไปหน้าแก้ไข และรอรับผลลัพธ์กลับมาเพื่อ Refresh หน้า
  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result == true) {
      setState(() {}); // Refresh หน้าจอเมื่อกลับมาจากหน้าแก้ไข
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ของฉัน')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // รูปโปรไฟล์ใหญ่
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(currentUser.imageUrl),
            ),
            const SizedBox(height: 16),

            // ชื่อ-สกุล
            Text(
              '${currentUser.firstName} ${currentUser.lastName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'รหัส: ${currentUser.studentId}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // การ์ดข้อมูล
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('คณะ', currentUser.faculty),
                      const Divider(),
                      _buildInfoRow('สาขา', currentUser.major),
                      const Divider(),
                      _buildInfoRow('ชั้นปี', 'ปี ${currentUser.year}'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ปุ่มแก้ไขข้อมูล
            ElevatedButton.icon(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit),
              label: const Text('แก้ไขข้อมูลส่วนตัว'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
