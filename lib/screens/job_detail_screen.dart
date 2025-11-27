// lib/screens/job_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  // ฟังก์ชันกดรับงาน
  Future<void> _acceptJob(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันรับงาน'),
        content: Text('คุณต้องการรับงาน "${job.title}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'รับงาน',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // อัปเดตสถานะใน Firestore
        await FirebaseFirestore.instance.collection('jobs').doc(job.id).update({
          'status': 'accepted',
          'acceptedBy': user.uid,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('รับงานสำเร็จ! ผู้จ้างจะเห็นข้อมูลของคุณ'),
            ),
          );
          Navigator.pop(context); // กลับไปหน้าแรก
        }
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == job.createdBy;
    final bool isAccepted = job.status == 'accepted';

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดงาน')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              job.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAccepted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAccepted ? 'มีคนรับแล้ว' : 'กำลังหาคน',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.price,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildInfoRow(Icons.location_on, 'สถานที่:', job.location),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.description,
                    'รายละเอียด:',
                    job.description,
                  ),

                  // ถ้างานถูกรับแล้ว และเราเป็นเจ้าของ ให้โชว์ว่าใครรับ
                  if (isAccepted && isOwner) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text(
                      'ข้อมูลคนรับงาน:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'User ID: ${job.acceptedBy ?? "-"}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _buildActionButton(context, isOwner, isAccepted),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isOwner,
    bool isAccepted,
  ) {
    // 1. ถ้าเราเป็นเจ้าของงาน
    if (isOwner) {
      return OutlinedButton(
        onPressed: () {
          // ในอนาคตอาจจะทำหน้าแก้ไขที่นี่
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไปที่หน้า "งานของฉัน" เพื่อลบหรือแก้ไข'),
            ),
          );
        },
        child: const Text('จัดการงาน (เจ้าของ)'),
      );
    }

    // 2. ถ้างานถูกรับไปแล้ว (และเราไม่ใช่เจ้าของ)
    if (isAccepted) {
      return const FilledButton(
        onPressed: null, // Disable ปุ่ม
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.grey),
        ),
        child: Text('งานนี้ปิดรับแล้ว'),
      );
    }

    // 3. ถ้างานยังว่าง (ให้กดรับงาน)
    return FilledButton(
      onPressed: () => _acceptJob(context),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.orange,
      ),
      child: const Text(
        'รับงานนี้ (Accept Job)',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
