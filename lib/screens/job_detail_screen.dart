import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cprujobapp/models/job_model.dart'; // ตรวจสอบ path ให้ถูก

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isAccepted = false; // ตัวแปรเช็คสถานะหน้างาน
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // เช็คเบื้องต้นว่างานนี้มีคนรับไปหรือยัง (ถ้าใน model มี field นี้)
    // _isAccepted = widget.job.status == 'accepted';
  }

  // ฟังก์ชันกดรับงาน
  Future<void> _acceptJob() async {
    // 1. ถามยืนยัน
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการรับงาน'),
        content: Text('คุณต้องการรับงาน "${widget.job.title}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 2. อัปเดต Firebase
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .update({
            'status': 'accepted', // เปลี่ยนสถานะ
            'acceptedBy': _currentUserId, // บันทึกว่าใครเป็นคนรับ
            'acceptedAt': FieldValue.serverTimestamp(), // บันทึกเวลา
          });

      setState(() {
        _isAccepted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รับงานสำเร็จ! เริ่มงานได้เลย')),
        );
        Navigator.pop(context); // ปิดหน้านี้กลับไปหน้า Home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // เช็คว่าเป็นเจ้าของโพสต์เองรึเปล่า (ถ้าใช่ ไม่ควรให้กดรับงานตัวเอง)
    bool isOwner = widget.job.createdBy == _currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดงาน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.job.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ชื่อและราคา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.job.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '฿${widget.job.price}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // สถานที่
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 4),
                Text(widget.job.location, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // รายละเอียด
            const Text(
              'รายละเอียด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),

      // ปุ่มด้านล่าง
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: isOwner
            ? OutlinedButton.icon(
                onPressed: () {
                  // อาจจะใส่ฟังก์ชันแก้ไข หรือลบตรงนี้ก็ได้
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('นี่คือประกาศของคุณเอง')),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('จัดการประกาศของฉัน'),
              )
            : FilledButton.icon(
                onPressed: _isAccepted
                    ? null
                    : _acceptJob, // ถ้ากดรับแล้ว ปุ่มจะกดไม่ได้
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isAccepted
                      ? Colors.grey
                      : null, // เปลี่ยนสีถ้าถูกรับแล้ว
                ),
                icon: Icon(_isAccepted ? Icons.check : Icons.handshake),
                label: Text(
                  _isAccepted ? 'งานนี้มีคนรับแล้ว' : 'รับงานนี้ (Accept Job)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
