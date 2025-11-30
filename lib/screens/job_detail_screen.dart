import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cprujobapp/models/job_model.dart';
import 'package:cprujobapp/widgets/full_screen_image.dart';
import 'package:cprujobapp/screens/post_job_screen.dart';
import 'package:cprujobapp/screens/chat_room_screen.dart'; // Ensure this import is correct

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  int _currentImageIndex = 0;
  bool _isAccepted = false;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _isAccepted = widget.job.status == 'accepted';
  }

  Future<void> _startChat() async {
    try {
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
              targetUserId: widget.job.createdBy,
              targetUserName: userData['firstName'] ?? 'User',
              targetUserImage: userData['imageUrl'] ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
    }
  }

  Future<void> _acceptJob(BuildContext context) async {
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
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('รับงาน'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('รับงานสำเร็จ!')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.job.createdBy == _currentUserId;

    // Use a default image list if empty to prevent errors
    final List<String> displayImages = widget.job.imageUrls.isNotEmpty
        ? widget.job.imageUrls
        : ['https://via.placeholder.com/400x300?text=No+Image'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดงาน'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostJobScreen(
                    job: widget.job,
                  ), // Assuming PostJobScreen handles editing
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Carousel ---
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageView(
                      imageUrls: displayImages,
                      initialIndex: _currentImageIndex,
                    ),
                  ),
                );
              },
              child: Container(
                height: 300,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      itemCount: displayImages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentImageIndex = index),
                      itemBuilder: (context, index) {
                        return Image.network(
                          displayImages[index],
                          fit:
                              BoxFit.contain, // Ensures the whole image is seen
                          errorBuilder: (ctx, err, stack) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                    if (displayImages.length > 1)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${displayImages.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- Details ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.job.authorAvatar.isNotEmpty
                              ? widget.job.authorAvatar
                              : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                        ),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job.authorName.isNotEmpty
                                ? widget.job.authorName
                                : 'ไม่ระบุชื่อ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'ผู้จ้างวาน',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_isAccepted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'มีคนรับแล้ว',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Title & Price
                  Text(
                    widget.job.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.job.price} บาท',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location & Description
                  _infoRow(Icons.location_on, 'สถานที่', widget.job.location),
                  const SizedBox(height: 12),
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

      // --- Bottom Action Bar ---
      bottomNavigationBar: (isOwner || _isAccepted)
          ? null
          : Container(
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
              child: Row(
                children: [
                  // Chat Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _startChat,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('ทักแชท'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Accept Button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _acceptJob(context),
                      icon: const Icon(Icons.handshake),
                      label: const Text('รับงานนี้'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
