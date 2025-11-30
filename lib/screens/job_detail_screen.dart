import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cprujobapp/models/job_model.dart';
import 'package:cprujobapp/screens/chat_room_screen.dart';
import 'package:cprujobapp/screens/post_job_screen.dart';
// ✅ Import Widget Slider ที่เราเพิ่งสร้าง
import 'package:cprujobapp/widgets/product_image_slider.dart';

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

  // ฟังก์ชันเริ่มแชท
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

  // ฟังก์ชันรับงาน
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
        setState(() => _isAccepted = true);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('รับงานสำเร็จ!')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.job.createdBy == _currentUserId;

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
                  builder: (_) => PostJobScreen(job: widget.job),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ------------------------------------------------
          // 🖥️ Desktop View (จอใหญ่ > 900px) : แบ่งครึ่งซ้ายขวา
          // ------------------------------------------------
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [ฝั่งซ้าย 50%] : แกลเลอรี่รูปภาพ (พื้นหลังดำ)
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.white,
                    height: double.infinity,
                    // ✅ เรียกใช้ Slider ตรงนี้
                    child: Center(
                      child: ProductImageSlider(
                        imageUrls: widget.job.imageUrls,
                      ),
                    ),
                  ),
                ),

                // [ฝั่งขวา 50%] : ข้อมูล + ปุ่มกด
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: _buildContent(context, isOwner), // เนื้อหา
                        ),
                      ),
                      // ปุ่มกด (อยู่ล่างสุดของฝั่งขวา)
                      _buildBottomActionBar(context, isOwner, isDesktop: true),
                    ],
                  ),
                ),
              ],
            );
          }

          // ------------------------------------------------
          // 📱 Mobile View (จอเล็ก) : เรียงลงมา
          // ------------------------------------------------
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 1. แกลเลอรี่รูปภาพ (อยู่บนสุด)
                      Container(
                        color: Colors.white,
                        // ✅ เรียกใช้ Slider ตรงนี้
                        child: ProductImageSlider(
                          imageUrls: widget.job.imageUrls,
                        ),
                      ),
                      // 2. เนื้อหา
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildContent(context, isOwner),
                      ),
                    ],
                  ),
                ),
              ),
              // 3. ปุ่มกด (อยู่ล่างสุด)
              _buildBottomActionBar(context, isOwner, isDesktop: false),
            ],
          );
        },
      ),
    );
  }

  // --- Widget เนื้อหา (ใช้ร่วมกันทั้ง Mobile/Desktop) ---
  Widget _buildContent(BuildContext context, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ผู้โพสต์
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                widget.job.authorAvatar.isNotEmpty
                    ? widget.job.authorAvatar
                    : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.authorName.isNotEmpty
                      ? widget.job.authorName
                      : 'ไม่ระบุชื่อ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

        // ชื่องาน & ราคา
        Text(
          widget.job.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.job.price} บาท',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // รายละเอียด
        _infoRow(Icons.location_on, 'สถานที่', widget.job.location),
        const SizedBox(height: 12),
        _infoRow(Icons.description, 'รายละเอียด', widget.job.description),
      ],
    );
  }

  // --- Widget ปุ่มกดด้านล่าง ---
  Widget _buildBottomActionBar(
    BuildContext context,
    bool isOwner, {
    required bool isDesktop,
  }) {
    if (isOwner || _isAccepted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (!isDesktop) // เงาเฉพาะมือถือ
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
        ],
        border: isDesktop
            ? const Border(top: BorderSide(color: Colors.black12))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _startChat,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('ทักแชท'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () => _acceptJob(context),
              icon: const Icon(Icons.handshake),
              label: const Text('รับงานนี้'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
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
              Text(value, style: const TextStyle(fontSize: 16, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
