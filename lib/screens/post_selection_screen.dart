import 'package:flutter/material.dart';
import 'package:cprujobapp/screens/post_job_screen.dart';

class PostSelectionScreen extends StatelessWidget {
  const PostSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างโพสต์ใหม่')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'คุณต้องการทำอะไรวันนี้?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // ปุ่ม 1: โพสต์หางาน
            Expanded(
              child: _buildSelectionCard(
                context,
                title: 'โพสต์ประกาศหางาน',
                subtitle: 'หาคนช่วยหิ้วของ, ติวหนังสือ, หรือช่วยงานทั่วไป',
                icon: Icons.search,
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ไปหน้ากรอกฟอร์ม หางาน...')),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ปุ่ม 2: สร้างโปรไฟล์รับงาน
            Expanded(
              child: _buildSelectionCard(
                context,
                title: 'สร้างโปรไฟล์รับงาน',
                subtitle: 'โปรโมททักษะของคุณ รับงานฟรีแลนซ์ หารายได้เสริม',
                icon: Icons.person_add_alt_1,
                color: Colors.blueGrey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostJobForm(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
