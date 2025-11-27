// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/image_service.dart'; // Import Image Service
import 'login_screen.dart';
import 'my_jobs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  // ฟังก์ชันเปลี่ยนรูปโปรไฟล์
  Future<void> _updateProfilePicture() async {
    // 1. เลือกรูป
    File? imageFile = await ImageService.pickImage();
    if (imageFile == null) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 2. อัปโหลดรูป
      String? downloadUrl = await ImageService.uploadImage(
        imageFile,
        'user_profiles/${user.uid}',
      );

      if (downloadUrl != null) {
        // 3. อัปเดต Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'imageUrl': downloadUrl});

        // 4. อัปเดต Global Variable (เพื่อให้หน้าอื่นเห็นรูปใหม่ทันที)
        currentUser.imageUrl = downloadUrl;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('อัปเดตรูปโปรไฟล์เรียบร้อย')),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header ---
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // รูปโปรไฟล์ + ปุ่มแก้ไข
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _isUploading
                              ? const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: CircularProgressIndicator(),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                    currentUser.imageUrl,
                                  ),
                                  onBackgroundImageError: (_, __) {},
                                ),
                        ),
                        // ปุ่มกล้องถ่ายรูป
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _updateProfilePicture, // กดแล้วเปลี่ยนรูป
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${currentUser.firstName} ${currentUser.lastName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentUser.faculty} | ${currentUser.studentId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Menus ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment_ind_rounded,
                    title: 'ประกาศงานของฉัน (My Jobs)',
                    subtitle: 'ดูรายการงานที่คุณเคยโพสต์ไว้',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyJobsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: 'ตั้งค่า (Settings)',
                    subtitle: 'แก้ไขข้อมูลส่วนตัว, เปลี่ยนรหัสผ่าน',
                    onTap: () {},
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('ออกจากระบบ'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
