import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import '../widgets/full_screen_image.dart';
import 'post_job_screen.dart';
// import 'chat_room_screen.dart'; // เปิด comment เมื่อมีไฟล์นี้

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
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE64A19),
            ),
            child: const Text('ยืนยันรับงาน'),
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
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == widget.job.createdBy;
    final bool isAccepted = widget.job.status == 'accepted';

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          extendBodyBehindAppBar: !isDesktop, // ให้รูปขึ้นไปสุดขอบบนมือถือ
          appBar: AppBar(
            backgroundColor: isDesktop ? Colors.white : Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDesktop ? Colors.black : Colors.white,
            ),
            title: isDesktop
                ? const Text(
                    'รายละเอียดงาน',
                    style: TextStyle(color: Colors.black),
                  )
                : null,
            actions: [
              if (isOwner)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostJobScreen(job: widget.job),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: isDesktop
              ? _buildDesktopLayout(context, isOwner, isAccepted)
              : _buildMobileLayout(context, isOwner, isAccepted),

          bottomNavigationBar: isDesktop
              ? null
              : _buildBottomActionBar(context, isOwner, isAccepted),
        );
      },
    );
  }

  // --- Desktop Layout (Split View) ---
  Widget _buildDesktopLayout(
    BuildContext context,
    bool isOwner,
    bool isAccepted,
  ) {
    return Row(
      children: [
        // Left: Gallery
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.black,
            child: _buildImageGallery(isDesktop: true),
          ),
        ),
        // Right: Content
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 30,
                  ),
                  child: _buildContent(context, isAccepted),
                ),
              ),
              _buildBottomActionBar(
                context,
                isOwner,
                isAccepted,
                isDesktop: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(
    BuildContext context,
    bool isOwner,
    bool isAccepted,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildImageGallery(isDesktop: false),
          Container(
            transform: Matrix4.translationValues(
              0.0,
              -20.0,
              0.0,
            ), // ดึงขึ้นมาทับรูปนิดนึง
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: _buildContent(context, isAccepted),
          ),
        ],
      ),
    );
  }

  // --- Components ---

  Widget _buildImageGallery({required bool isDesktop}) {
    final double height = isDesktop
        ? double.infinity
        : MediaQuery.of(context).size.height * 0.45;

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: PageView.builder(
            itemCount: widget.job.imageUrls.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(
                        imageUrls: widget.job.imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  widget.job.imageUrls[index],
                  fit: isDesktop ? BoxFit.contain : BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Fullscreen Icon
        Positioned(
          top: isDesktop ? 20 : MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: IconButton(
            onPressed: () {
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
            icon: const Icon(Icons.fullscreen, color: Colors.white, size: 30),
            style: IconButton.styleFrom(backgroundColor: Colors.black45),
          ),
        ),

        // Indicators
        if (widget.job.imageUrls.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
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
                        : Colors.white54,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isAccepted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isAccepted
                ? Colors.green.withOpacity(0.1)
                : const Color(0xFFE64A19).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isAccepted ? '✅ มีคนรับแล้ว' : '🔥 กำลังหาคน',
            style: TextStyle(
              color: isAccepted ? Colors.green : const Color(0xFFE64A19),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          widget.job.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Price & Location
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${widget.job.price} บาท',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE64A19),
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.job.location,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Seller Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(widget.job.authorAvatar),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.authorName,
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
              ),
              OutlinedButton(
                onPressed: () {
                  // TODO: Go to user profile
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'ดูโปรไฟล์',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Description
        const Text(
          'รายละเอียดงาน',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          widget.job.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 100), // Space for bottom bar
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    bool isOwner,
    bool isAccepted, {
    bool isDesktop = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: isDesktop
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: Row(
        children: [
          // Chat Button
          if (!isOwner)
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(...)));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming Soon...')),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('ทักแชท'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE64A19)),
                  foregroundColor: const Color(0xFFE64A19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          if (!isOwner) const SizedBox(width: 16),

          // Main Action Button (Accept / Close)
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: (isOwner || isAccepted)
                  ? null
                  : () => _acceptJob(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE64A19),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isOwner
                    ? 'โพสต์ของคุณ'
                    : (isAccepted ? 'งานปิดแล้ว' : 'รับงานนี้'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
