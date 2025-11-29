import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cprujobapp/models/job_model.dart';
import 'package:cprujobapp/screens/job_detail_screen.dart';
import 'package:cprujobapp/screens/post_job_screen.dart';
import 'package:cprujobapp/screens/market_screen.dart';
import 'package:cprujobapp/screens/profile_screen.dart';
import 'package:cprujobapp/screens/post_product_screen.dart';
import 'package:cprujobapp/screens/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // ตัวแปรสำหรับ Filter งาน
  final List<String> _jobCategories = [
    'ทั้งหมด',
    'อาหาร',
    'ขนของ',
    'ติวหนังสือ',
    'ทำความสะอาด',
    'ทั่วไป',
  ];
  String _selectedJobCategory = 'ทั้งหมด';

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            children: [
              const Text(
                'คุณต้องการทำอะไร?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOptionButton(
                    icon: Icons.work,
                    label: 'ประกาศจ้างงาน',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostJobScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionButton(
                    icon: Icons.store,
                    label: 'ลงขายสินค้า',
                    color: Colors.blue,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                );
              },
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                        ? user!.photoURL!
                        : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                  ),
                  radius: 18,
                  onBackgroundImageError: (_, __) {},
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
              Tab(icon: Icon(Icons.store), text: 'ตลาดนัด'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Jobs
            Column(
              children: [
                Container(
                  height: 60,
                  color: Colors.white,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _jobCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _jobCategories[index];
                      final isSel = _selectedJobCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: Colors.orange.shade100,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.orange.shade900 : Colors.black,
                        ),
                        onSelected: (v) =>
                            setState(() => _selectedJobCategory = cat),
                      );
                    },
                  ),
                ),
                Expanded(child: _buildRealJobList(context)),
              ],
            ),

            // Tab 2: Market
            const MarketScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateOptions,
          backgroundColor: Colors.orange,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

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
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('ไม่พบงานในหมวดหมู่นี้'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            Job job = Job.fromFirestore(doc);

            // ✅✅✅ แก้ตรงนี้ครับ: ใช้ imageUrls แทน imageUrl ✅✅✅
            String thumb = 'https://via.placeholder.com/150'; // ค่าเริ่มต้น
            if (job.imageUrls.isNotEmpty) {
              thumb = job.imageUrls.first; // เอารูปแรกมาโชว์
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    thumb,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey[300],
                      width: 100,
                      height: 100,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.price} บาท',
                      style: const TextStyle(
                        color: Colors.orange,
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
}
