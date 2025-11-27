// lib/models/job_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String price;
  final String location;
  final String imageUrl;
  final String createdBy; // UID ของคนโพสต์
  final String status; // 'open' = ว่าง, 'accepted' = มีคนรับแล้ว
  final String? acceptedBy; // UID ของคนรับงาน (อาจจะเป็น null ได้)
  final DateTime? createdAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.createdBy,
    required this.status,
    this.acceptedBy,
    this.createdAt,
  });

  // Factory แปลงข้อมูลจาก Firestore เป็น Object
  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Job(
      id: doc.id,
      title: data['title'] ?? 'ไม่ระบุชื่อ',
      description: data['description'] ?? '',
      price: '${data['price'] ?? 0} บาท',
      location: data['location'] ?? 'ไม่ระบุสถานที่',
      imageUrl:
          data['imageUrl'] ??
          'https://via.placeholder.com/300x200.png?text=No+Image',
      createdBy: data['createdBy'] ?? '',

      // Default เป็น 'open' ถ้าไม่มีข้อมูลใน DB
      status: data['status'] ?? 'open',
      acceptedBy: data['acceptedBy'], // อาจเป็น null ได้
      // แปลง Timestamp เป็น DateTime
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
