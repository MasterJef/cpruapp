import 'package:cprujobapp/widgets/item_card.dart';
import 'package:cprujobapp/widgets/responsive_layout.dart';
import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Imports Models
import '../models/job_model.dart';
import '../models/user_model.dart'; // สำหรับ currentUser

// Imports Widgets

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
        .where('status', isEqualTo: 'open'); // กรองงานว่าง

    if (_selectedJobCategory != 'ทั้งหมด') {
      query = query.where('category', isEqualTo: _selectedJobCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('created_at', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty)
          return const Center(child: Text('ไม่พบงานในหมวดหมู่นี้'));

        // ✅ ใช้ LayoutBuilder เพื่อปรับ Responsive
        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2; // มือถือ 2 คอลัมน์
            if (constraints.maxWidth > 600) crossAxisCount = 3;
            if (constraints.maxWidth > 900) crossAxisCount = 4;

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.75, // สัดส่วนการ์ด
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                Job job = Job.fromFirestore(doc);

                // เช็ครูป (List -> String)
                String thumb = 'https://via.placeholder.com/150';
                if (job.imageUrls.isNotEmpty) thumb = job.imageUrls.first;

                // ✅ ใช้ ItemCard เหมือนหน้าตลาดนัดเป๊ะๆ
                return ItemCard(
                  title: job.title,
                  price: job.price, // ไม่ต้องเติม 'บาท' เพราะ ItemCard เติมให้
                  location: job.location, // ส่ง location ไป
                  imageUrl: thumb,
                  authorName: job.authorName,
                  authorAvatar: job.authorAvatar,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(job: job),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
