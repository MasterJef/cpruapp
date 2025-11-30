import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Imports Models
import '../models/job_model.dart';
import '../models/user_model.dart'; // สำหรับ currentUser

// Imports Widgets
import '../widgets/responsive_layout.dart';
import '../widgets/web_chat_overlay.dart';

// Imports Screens
import 'job_detail_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'post_job_screen.dart';
import 'market_screen.dart';
import 'post_product_screen.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- State สำหรับ Web Chat ---
  bool _isChatDropdownOpen = false;
  Map<String, dynamic>? _activeChatUser;
  bool _isChatMinimized = false; // ตัวแปรที่ถูกต้อง

  // --- State สำหรับ Filter งาน ---
  String _selectedJobCategory = 'ทั้งหมด';
  final List<String> _jobCategories = [
    'ทั้งหมด',
    'อาหาร',
    'ขนของ',
    'ติวหนังสือ',
    'ทำความสะอาด',
    'ทั่วไป',
  ];

  // ฟังก์ชัน Logout
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance
                  .signOut(); // เพิ่มบรรทัดนี้เพื่อเคลียร์ Firebase Auth
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('ออก', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันกดปุ่มแชท
  void _onChatIconPressed() {
    bool isLargeScreen = kIsWeb || MediaQuery.of(context).size.width > 600;

    if (isLargeScreen) {
      setState(() {
        _isChatDropdownOpen = !_isChatDropdownOpen;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatListScreen()),
      );
    }
  }

  // ฟังก์ชันแสดงตัวเลือกโพสต์
  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'เลือกสิ่งที่ต้องการสร้าง',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE64A19),
                  child: Icon(Icons.work, color: Colors.white),
                ),
                title: const Text('โพสต์ประกาศงาน'),
                subtitle: const Text('หาคนช่วยงาน, ขนของ, ติวหนังสือ'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PostJobScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.store, color: Colors.white),
                ),
                title: const Text('ลงขายสินค้า'),
                subtitle: const Text('เสื้อผ้ามือสอง, หนังสือ, อุปกรณ์'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PostProductScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: false,
              // ✅ เพิ่มปุ่ม Logout ด้านซ้าย (เพื่อแก้ Error _logout ไม่ถูกใช้)
              leading: IconButton(
                icon: const Icon(Icons.logout, color: Colors.grey),
                onPressed: _logout,
                tooltip: 'ออกจากระบบ',
              ),
              title: const Text(
                'UniJobs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE64A19),
                  fontSize: 24,
                ),
              ),
              actions: [
                // ปุ่ม Chat + Notification Badge
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .where(
                        'users',
                        arrayContains: FirebaseAuth.instance.currentUser?.uid,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    int unreadCount = 0;
                    if (snapshot.hasData) {
                      final myUid = FirebaseAuth.instance.currentUser?.uid;
                      for (var doc in snapshot.data!.docs) {
                        var data = doc.data() as Map<String, dynamic>;
                        if (data['readBy'] != null &&
                            data['readBy'][myUid] == false) {
                          unreadCount++;
                        }
                      }
                    }

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.black87,
                          ),
                          onPressed: _onChatIconPressed,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                // รูปโปรไฟล์
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(currentUser.imageUrl),
                      radius: 18,
                    ),
                  ),
                ),
              ],
              bottom: const TabBar(
                indicatorColor: Color(0xFFE64A19),
                labelColor: Color(0xFFE64A19),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(icon: Icon(Icons.campaign), text: 'ประกาศงาน'),
                  Tab(icon: Icon(Icons.store), text: 'ตลาดนัด'),
                ],
              ),
            ),

            body: ResponsiveContainer(
              child: TabBarView(
                children: [
                  // Tab 1: Jobs
                  Column(
                    children: [
                      _buildCategorySelector(),
                      Expanded(child: _buildRealJobList(context)),
                    ],
                  ),
                  // Tab 2: Market
                  const MarketScreen(),
                ],
              ),
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: _showCreateOptions,
              backgroundColor: const Color(0xFFE64A19),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),

          // --- Web Chat Overlay ---
          if (kIsWeb || MediaQuery.of(context).size.width > 600)
            WebChatOverlay(
              showDropdown: _isChatDropdownOpen,
              activeChatTarget: _activeChatUser,
              isMinimized: _isChatMinimized,
              onChatSelected: (user) {
                setState(() {
                  _activeChatUser = user;
                  _isChatDropdownOpen = false;
                  // ✅ แก้ไขชื่อตัวแปรตรงนี้ครับ
                  _isChatMinimized = false;
                });
              },
              onCloseChat: () {
                setState(() => _activeChatUser = null);
              },
              onMinimizeChat: () {
                setState(() => _isChatMinimized = !_isChatMinimized);
              },
            ),
        ],
      ),
    );
  }

  // --- Helper Widget: ปุ่มเลือกหมวดหมู่งาน ---
  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _jobCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _jobCategories[index];
          final isSel = _selectedJobCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedJobCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSel
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: isSel ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSel ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widget: รายการงาน ---
  Widget _buildRealJobList(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('jobs')
        .where('status', isEqualTo: 'open');

    if (_selectedJobCategory != 'ทั้งหมด') {
      query = query.where('category', isEqualTo: _selectedJobCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('created_at', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text(
                  'ไม่พบงานในหมวดหมู่นี้',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 คอลัมน์
            childAspectRatio: 0.75, // สัดส่วนการ์ด (สูงกว่ากว้าง)
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            Job job = Job.fromFirestore(doc);
            String thumb = job.imageUrls.isNotEmpty
                ? job.imageUrls.first
                : 'https://via.placeholder.com/150';

            // ใช้ ItemCard (แบบเดียวกับ Market) เพื่อความสวยงามและ Code Clean
            // แต่ถ้ายังไม่มี ItemCard ให้ใช้ Card แบบเดิมแต่จัด Layout ใหม่
            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                ),
                child: Column(
                  // เปลี่ยนจาก Row เป็น Column
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. รูปภาพ (ด้านบน)
                    Expanded(
                      child: Container(
                        color: Colors.black, // พื้นหลังดำให้ดูดี
                        width: double.infinity,
                        child: Image.network(
                          thumb,
                          fit: BoxFit.contain, // เห็นรูปครบ
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),

                    // 2. ข้อมูล (ด้านล่าง)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  job.location,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${job.price} ฿',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // รูปคนโพสต์เล็กๆ
                              CircleAvatar(
                                radius: 8,
                                backgroundImage: NetworkImage(
                                  job.authorAvatar.isNotEmpty
                                      ? job.authorAvatar
                                      : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
