import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import '../widgets/full_screen_image.dart'; // Import Widget ดูรูปเต็มจอ
import 'post_job_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  int _currentImageIndex = 0; // เก็บตำแหน่งรูปปัจจุบัน

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
              child: Container(
                height: 300,
                color: Colors.black, // พื้นหลังดำให้ดูพรีเมียม
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      itemCount: widget.job.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.job.imageUrls[index],
                          fit: BoxFit.contain, // รูปไม่โดนตัด
                        );
                      },
                    ),
                    // Dots Indicator
                    if (widget.job.imageUrls.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.job.imageUrls.length, (
                            index,
                          ) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
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
          : Container(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => _acceptJob(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'รับงานนี้',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
