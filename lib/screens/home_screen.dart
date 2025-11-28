// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/job_model.dart';
import '../models/user_model.dart';

import 'job_detail_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'post_job_screen.dart';
// import 'freelancer_detail_screen.dart'; // ไม่ใช้แล้ว
import 'market_screen.dart'; // <--- Import ใหม่
import 'post_product_screen.dart'; // <--- Import ใหม่

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ฟังก์ชัน Logout (คงเดิม)
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

  // ฟังก์ชันแสดง Dialog เลือกประเภทโพสต์
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
                  backgroundColor: Colors.orange,
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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          centerTitle: true,
          title: const Text(
            'UniJobs',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
          actions: [
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
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(currentUser.imageUrl),
                  radius: 18,
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.campaign), text: 'ประกาศงาน'),
              Tab(
                icon: Icon(Icons.store),
                text: 'ตลาดนัด',
              ), // <--- เปลี่ยนชื่อ Tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRealJobList(context), // Tab 1: Jobs (Logic เดิม)
            const MarketScreen(), // Tab 2: Market (Logic ใหม่)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateOptions, // <--- เปลี่ยน Action ปุ่ม FAB
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  // (คง Logic _buildRealJobList ไว้เหมือนเดิมด้านล่างนี้...)
  Widget _buildRealJobList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'open')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Job job = Job.fromFirestore(snapshot.data!.docs[index]);
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          job.imageUrls.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // แก้บั๊กราคาซ้ำ: ใน Model เราเก็บแค่ตัวเลขแล้ว ดังนั้นเติม "บาท" ได้เลย
                            Text(
                              '${job.price} บาท',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    job.authorAvatar,
                                  ),
                                  radius: 10,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  job.authorName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
              ),
            );
          },
        );
      },
    );
  }
}
