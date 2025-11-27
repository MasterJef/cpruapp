import 'package:flutter/material.dart';
import '../models/user_model.dart'; // เพื่อเรียกใช้ currentUser
import '../services/auth_service.dart'; // เพื่อเรียก Logout
import 'login_screen.dart';
import 'my_jobs_screen.dart'; // ลิงก์ไปหน้างานของฉัน

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ฟังก์ชันออกจากระบบ
  void _handleLogout(BuildContext context) async {
    // เรียก Service เพื่อ Sign out จาก Firebase
    await AuthService().logout();

    if (context.mounted) {
      // เคลียร์ Stack หน้าเก่าทิ้งทั้งหมด แล้วไปหน้า Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // สีธีมหลัก
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50], // พื้นหลังสีอ่อนขรึมๆ
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ส่วน Header ---
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
                  // รูปโปรไฟล์
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(currentUser.imageUrl),
                        onBackgroundImageError:
                            (_, __) {}, // กัน Error ถ้ารูปพัง
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ชื่อ-นามสกุล
                  Text(
                    '${currentUser.firstName} ${currentUser.lastName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // รหัสนักศึกษา / อีเมล (สมมติว่าใช้อีเมลเป็น ID หรือโชว์ Faculty แทนก็ได้)
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

            // --- ส่วนเมนู (Menu Items) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 1. เมนูประกาศงานของฉัน
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment_ind_rounded,
                    title: 'ประกาศงานของฉัน (My Jobs)',
                    subtitle: 'ดูรายการงานที่คุณเคยโพสต์ไว้',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyJobsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 2. เมนูอื่นๆ (Placeholder เผื่ออนาคต)
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: 'ตั้งค่า (Settings)',
                    subtitle: 'แก้ไขข้อมูลส่วนตัว, เปลี่ยนรหัสผ่าน',
                    onTap: () {
                      // ยังไม่ได้ทำหน้า Edit Profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ฟีเจอร์นี้กำลังพัฒนา...'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // 3. ปุ่มออกจากระบบ
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context),
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

  // Helper Widget สร้างเมนูสวยๆ
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
