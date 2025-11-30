import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import '../widgets/full_screen_image.dart';
import 'post_job_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  int _currentImageIndex = 0;

  // Logic รับงาน
  Future<void> _acceptJob(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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
            child: const Text(
              'รับงาน',
              style: TextStyle(
                color: Color(0xFFE64A19),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
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
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == widget.job.createdBy;
    final bool isAccepted = widget.job.status == 'accepted';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint ที่ 900px
        bool isDesktop = constraints.maxWidth > 900;

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
          // Desktop: Layout แบบ Split View (ไม่มี BottomBar)
          // Mobile: Layout แบบ Scroll (มี BottomBar)
          body: isDesktop
              ? _buildDesktopLayout(context, isOwner, isAccepted)
              : _buildMobileLayout(context, isOwner, isAccepted),

          bottomNavigationBar: isDesktop
              ? null
              : _buildBottomAction(
                  context,
                  isOwner,
                  isAccepted,
                  isMobile: true,
                ),
        );
      },
    );
  }

  // --- Layouts ---

  Widget _buildDesktopLayout(
    BuildContext context,
    bool isOwner,
    bool isAccepted,
  ) {
    return Row(
      children: [
        // ฝั่งซ้าย: รูปภาพ (50%)
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.black, // พื้นหลังดำสำหรับ Gallery
            child: _buildImageGallery(isDesktop: true),
          ),
        ),
        // ฝั่งขวา: ข้อมูล (50%)
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: _buildJobInfo(),
                ),
              ),
              // ปุ่มกดสำหรับ Desktop (วางไว้ด้านล่างของฝั่งขวา)
              _buildBottomAction(context, isOwner, isAccepted, isMobile: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    bool isOwner,
    bool isAccepted,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(isDesktop: false),
          Padding(padding: const EdgeInsets.all(20), child: _buildJobInfo()),
        ],
      ),
    );
  }

  // --- Components ---

  Widget _buildImageGallery({required bool isDesktop}) {
    // ถ้าเป็น Desktop ให้เต็มพื้นที่, ถ้า Mobile สูง 300
    final double? height = isDesktop ? double.infinity : 300;

    return GestureDetector(
      onTap: () {
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
        height: height,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: widget.job.imageUrls.length,
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  widget.job.imageUrls[index],
                  fit: BoxFit.contain, // รูปไม่โดนตัด
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            if (widget.job.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.job.imageUrls.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? const Color(0xFFE64A19)
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author Info
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.job.authorAvatar),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'ผู้จ้างวาน',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.job.status == 'accepted'
                    ? Colors.green[100]
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.job.status == 'accepted' ? 'มีคนรับแล้ว' : 'ว่าง',
                style: TextStyle(
                  color: widget.job.status == 'accepted'
                      ? Colors.green[800]
                      : Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 40),

        // Title & Price
        Text(
          widget.job.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.job.price} บาท',
          style: const TextStyle(
            fontSize: 24,
            color: Color(0xFFE64A19),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Details
        _infoRow(Icons.location_on, 'สถานที่', widget.job.location),
        const SizedBox(height: 16),
        _infoRow(Icons.description, 'รายละเอียด', widget.job.description),
      ],
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    bool isOwner,
    bool isAccepted, {
    required bool isMobile,
  }) {
    // ถ้าเป็นเจ้าของ หรือ งานถูกรับแล้ว ไม่ต้องโชว์ปุ่มรับงาน (หรือโชว์เป็น disabled)
    if (isOwner || isAccepted) {
      return isMobile ? const SizedBox.shrink() : const SizedBox.shrink();
      // หรือจะ return ปุ่ม disabled text ก็ได้
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isMobile
            ? [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
        border: !isMobile
            ? Border(top: BorderSide(color: Colors.grey.shade200))
            : null,
      ),
      child: FilledButton(
        onPressed: () => _acceptJob(context),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE64A19),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'รับงานนี้',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
