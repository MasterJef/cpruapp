import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart'; // เรียกใช้ Model
import 'job_detail_screen.dart'; // เผื่อกดเข้าไปดูรายละเอียดก่อนลบ

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  // ฟังก์ชันลบงาน
  Future<void> _deleteJob(BuildContext context, String jobId) async {
    // แสดง Dialog ยืนยันก่อนลบ
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text(
          'คุณต้องการลบประกาศงานนี้ใช่หรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // ตอบ No
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // ตอบ Yes
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // ถ้ากด Yes (true) ให้ทำการลบ
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ลบงานเรียบร้อยแล้ว')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึง UID ของคนปัจจุบัน
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text('กรุณาเข้าสู่ระบบใหม่')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ประกาศงานของฉัน'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query: เลือกเฉพาะ jobs ที่ createdBy ตรงกับ UID เรา
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('createdBy', isEqualTo: currentUserId)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. กำลังโหลด
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. เกิด Error
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          // 3. ไม่มีข้อมูล
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'คุณยังไม่เคยประกาศงาน',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 4. มีข้อมูล -> แสดงรายการ
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // แปลงข้อมูลเป็น Job Object
              final doc = snapshot.data!.docs[index];
              final job = Job.fromFirestore(doc);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // รูปภาพงาน (ซ้าย)
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      job.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  // ข้อมูลงาน (กลาง)
                  title: Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.location, style: const TextStyle(fontSize: 12)),
                      Text(
                        job.price,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // ปุ่มลบ (ขวา)
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteJob(context, job.id),
                    tooltip: 'ลบประกาศนี้',
                  ),
                  // กดที่การ์ดเพื่อดูรายละเอียด
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
