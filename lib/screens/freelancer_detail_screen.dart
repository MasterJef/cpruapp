import 'package:flutter/material.dart';
import '../models/mock_data.dart';

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
            // รูปโปรไฟล์วงกลม
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

            // Rating Bar (ทำเองง่ายๆ)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < freelancer.rating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${freelancer.rating})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                freelancer.bio,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 20),
            // กล่องราคาเริ่มต้น
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'ราคาเริ่มต้น',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    freelancer.startingPrice,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ปุ่มจ้างงาน
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ส่งข้อความหา ${freelancer.name} แล้ว!')),
            );
          },
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('จ้างงานคนนี้ (Hire Me)'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
