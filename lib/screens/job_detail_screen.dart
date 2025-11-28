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
  bool _isAccepted = false;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _isAccepted = widget.job.status == 'accepted';
  }

  Future<void> _acceptJob() async {
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
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .update({
            'status': 'accepted',
            'acceptedBy': _currentUserId,
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      setState(() {
        _isAccepted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รับงานสำเร็จ! เริ่มงานได้เลย')),
        );
        Navigator.pop(context);
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
    bool isOwner = widget.job.createdBy == _currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดงาน')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- โซนรูปภาพ (แก้ใหม่ให้สวยขึ้น) ---
            Container(
              width: double.infinity,
              height: 300, // เพิ่มความสูงให้ดูเต็มตา
              decoration: const BoxDecoration(
                color: Colors.black, // พื้นหลังดำ ขับให้รูปเด่น
              ),
              child: GestureDetector(
                onTap: () {
                  // กดเพื่อดูรูปเต็มจอ (Zoom)
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: InteractiveViewer(
                              child: Image.network(
                                widget.job.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Hero(
                  // เอฟเฟกต์เด้งสวยๆ
                  tag: widget.job.id, // ต้องใช้ id ที่ไม่ซ้ำกัน
                  child: Image.network(
                    widget.job.imageUrl,
                    fit: BoxFit.contain, // ✅ เปลี่ยนเป็น contain (ไม่โดนตัด)
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (ctx, err, stack) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                        Text(
                          "โหลดรูปไม่ได้",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // -------------------------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อและราคา
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(width: 10),
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
                      Expanded(
                        child: Text(
                          widget.job.location,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
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
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.job.status == 'accepted')
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'คนรับงานนี้คือ: \n${widget.job.acceptedBy ?? "ไม่ระบุ"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('คุณคือเจ้าของงานนี้')),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('จัดการประกาศ'),
                  ),
                ],
              )
            : FilledButton.icon(
                onPressed: _isAccepted ? null : _acceptJob,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isAccepted ? Colors.grey : null,
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
