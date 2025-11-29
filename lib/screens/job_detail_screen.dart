import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import '../widgets/full_screen_image.dart'; // Import Widget ดูรูปเต็มจอ
import 'post_job_screen.dart';
import 'package:cprujobapp/screens/chat_room_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  int _currentImageIndex = 0; // เก็บตำแหน่งรูปปัจจุบัน

  // เพิ่มฟังก์ชันนี้ไว้ใน _JobDetailScreenState
  // แก้ไขฟังก์ชันนี้ใน job_detail_screen.dart
  Future<void> _startChat() async {
    try {
      // 1. ดึงข้อมูลเจ้าของงาน
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.job.createdBy)
          .get();

      if (!userDoc.exists) return;

      var userData = userDoc.data() as Map<String, dynamic>;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              // 👇👇 แก้ชื่อตัวแปรตรงนี้ให้ตรงกับ Error ครับ 👇👇
              targetUserId: widget.job.createdBy, // เดิมอาจเป็น targetUid
              targetUserName:
                  userData['firstName'] ?? 'User', // เดิมอาจเป็น targetName
              targetUserImage:
                  userData['imageUrl'] ?? '', // เดิมอาจเป็น targetImage
            ),
          ),
        );
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> _acceptJob(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Logic รับงาน
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันรับงาน'),
        content: const Text('คุณต้องการรับงานนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('รับงาน'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .update({'status': 'accepted', 'acceptedBy': user.uid});
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('รับงานสำเร็จ!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == widget.job.createdBy;
    final bool isAccepted = widget.job.status == 'accepted';

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดงาน'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostJobScreen(job: widget.job),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Carousel (PageView) ---
            GestureDetector(
              onTap: () {
                // กดที่รูปเพื่อดูเต็มจอ
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageView(
                      imageUrls: widget.job.imageUrls,
                      initialIndex: _currentImageIndex,
                    ),
                  ),
                );
              },
              child: GestureDetector(
                onTap: () {
                  // กดแล้วไปหน้าดูรูปเต็มจอ
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(
                        imageUrls: widget.job.imageUrls, // ส่งไปทั้งลิสต์
                        initialIndex: _currentImageIndex,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 300, // ความสูงกำลังดี (ไม่สูงเกิน ไม่เตี้ยเกิน)
                  width: double.infinity,
                  color: Colors.grey[200], // สีพื้นหลังตอนโหลด
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      PageView.builder(
                        itemCount: widget.job.imageUrls.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          return Image.network(
                            widget.job.imageUrls[index],
                            fit: BoxFit
                                .cover, // ✅ ใช้ cover ให้เต็มสวยเหมือน Shopee
                            width: double.infinity,
                          );
                        },
                      ),
                      // ป้ายบอกจำนวนรูป (เช่น 1/3)
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.job.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ข้อมูลผู้โพสต์
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.job.authorAvatar),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ผู้จ้างวาน',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(isAccepted ? 'มีคนรับแล้ว' : 'ว่าง'),
                        backgroundColor: isAccepted
                            ? Colors.green[100]
                            : Colors.orange[100],
                        labelStyle: TextStyle(
                          color: isAccepted
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  Text(
                    widget.job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.job.price} บาท',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoRow(Icons.location_on, 'สถานที่', widget.job.location),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.description,
                    'รายละเอียด',
                    widget.job.description,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (isOwner || isAccepted)
          ? null
          : BottomAppBar(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _startChat,
                    icon: const Icon(Icons.chat),
                    tooltip: 'ทักแชท',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FloatingActionButton.extended(
                      onPressed: () => _acceptJob(context),
                      label: const Text('รับงานนี้'),
                      icon: const Icon(Icons.check),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
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
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
