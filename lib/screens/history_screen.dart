import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_detail_screen.dart';
import '../models/job_model.dart'; // ใช้ Model จริงเท่านั้น

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ประวัติการทำรายการ'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'งานที่ลงประกาศ'),
              Tab(text: 'บริการที่จ้าง'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildMyPosts(), _buildMyServices()]),
      ),
    );
  }

  Widget _buildMyPosts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('กรุณาเข้าสู่ระบบ'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('createdBy', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'คุณยังไม่เคยลงประกาศงาน',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // ใช้ Factory ตัวเดิม ง่ายและ Clean
            Job job = Job.fromFirestore(snapshot.data!.docs[index]);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    job.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                  ),
                ),
                title: Text(job.title, maxLines: 1),
                subtitle: Text('ราคา: ${job.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(job.id)
                      .delete(),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyServices() {
    return const Center(
      child: Text(
        'ส่วนนี้ยังไม่มีระบบ Backend (รอพัฒนา)',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
