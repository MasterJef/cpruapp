import 'package:flutter/material.dart';
import 'package:cprujobapp/models/job_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ 1. เพิ่ม import นี้

// Import หน้าจอต่างๆ
import 'package:cprujobapp/screens/login_screen.dart';
import 'package:cprujobapp/screens/profile_screen.dart';
import 'package:cprujobapp/screens/job_detail_screen.dart';
import 'package:cprujobapp/screens/freelancer_detail_screen.dart';
// เพิ่มบรรทัดนี้ครับ (เช็คชื่อไฟล์ให้ตรงกับที่คุณมี)// เพื่อใช้ class Job และ Freelancer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ✅ 2. ดึงข้อมูล User ปัจจุบันมารอไว้
  final User? user = FirebaseAuth.instance.currentUser;

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
              FirebaseAuth.instance.signOut(); // สั่ง Firebase ออกจากระบบด้วย
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  // ✅ 3. ถ้าไม่มีรูป ให้ใช้รูปกันตาย (Placeholder)
                  backgroundImage: NetworkImage(
                    user?.photoURL ??
                        'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                  ),
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
              Tab(icon: Icon(Icons.people), text: 'รวมยอดฝีมือ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRealJobList(context), // <--- ข้อมูลจริงจาก Firebase
            _buildFreelancerList(context), // <--- ข้อมูล Mock
          ],
        ),
      ),
    );
  }

  // Widget ดึงข้อมูลจริงจาก Firestore
  Widget _buildRealJobList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('โหลดข้อมูลล้มเหลว'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'ยังไม่มีประกาศงาน',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // ✅ 4. ดึงข้อมูลดิบมา แล้วแปลงเป็น Job Object
            var doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // สร้าง Job แบบ Manual ตรงนี้เลย (กัน Error ที่ Model)
            // ใช้ Factory ที่เราเพิ่งสร้าง
            Job job = Job.fromFirestore(snapshot.data!.docs[index]);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    job.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                title: Text(
                  job.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '฿${job.price}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(job: job),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ส่วน Freelancer (ใช้ Mock Data เดิม)
  Widget _buildFreelancerList(BuildContext context) {
    if (mockFreelancers.isEmpty)
      return const Center(child: Text('ไม่มีข้อมูล Freelancer'));

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: mockFreelancers.length,
      itemBuilder: (context, index) {
        final freelancer = mockFreelancers[index];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FreelancerDetailScreen(freelancer: freelancer),
            ),
          ),
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    freelancer.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: Colors.grey[300]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        freelancer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      Text(
                        freelancer.skill,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(' ${freelancer.rating}'),
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
  }
}
