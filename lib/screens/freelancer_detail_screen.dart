import 'package:flutter/material.dart';
// ✅ เปลี่ยนจาก mock_data เป็น freelancer_model
import 'package:cprujobapp/models/freelancer_model.dart';

class FreelancerDetailScreen extends StatelessWidget {
  final Freelancer freelancer;

  const FreelancerDetailScreen({super.key, required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ผู้ช่วย')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // รูปโปรไฟล์
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(freelancer.imageUrl),
              ),
            ),
            const SizedBox(height: 16),

            // ชื่อและทักษะ
            Text(
              freelancer.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              freelancer.skill,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${freelancer.rating}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Bio
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'เกี่ยวกับฉัน',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              freelancer.bio,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            // ราคาเริ่มต้น
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ราคาเริ่มต้น:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    freelancer.startingPrice,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ปุ่มจ้างงาน
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ส่งคำขอจ้าง ${freelancer.name} แล้ว!')),
              );
            },
            child: const Text('จ้างงานคนนี้'),
          ),
        ),
      ),
    );
  }
}
