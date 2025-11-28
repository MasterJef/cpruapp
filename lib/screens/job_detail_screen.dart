import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import 'post_job_screen.dart'; // เพื่อกดแก้ไข

class JobDetailScreen extends StatelessWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == job.createdBy;
    final bool isAccepted = job.status == 'accepted';

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดงาน'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostJobScreen(job: job)),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: job.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    job.imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(job.authorAvatar),
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ผู้จ้างวาน',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isAccepted ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAccepted ? 'มีคนรับแล้ว' : 'ว่าง',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  Text(
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${job.price} บาท',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _infoRow(Icons.location_on, 'สถานที่', job.location),
                  const SizedBox(height: 10),
                  _infoRow(Icons.description, 'รายละเอียด', job.description),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isOwner || isAccepted
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => _acceptJob(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'รับงานนี้',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _acceptJob(BuildContext context) async {
    // Logic รับงาน (เหมือนเดิม)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('jobs').doc(job.id).update({
      'status': 'accepted',
      'acceptedBy': user.uid,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รับงานสำเร็จ!')));
      Navigator.pop(context);
    }
  }
}
