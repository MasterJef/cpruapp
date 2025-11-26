import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String price;
  final String location;
  final String imageUrl;
  final String createdBy;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.createdBy,
  });

  // Factory Constructor: แปลงข้อมูลจาก Firebase มาเป็น Job Object
  // วิธีนี้ช่วยกันแอปพังถ้าข้อมูลบางช่องเป็น Null
  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Job(
      id: doc.id,
      title: data['title'] ?? 'ไม่ระบุชื่องาน',
      description: data['description'] ?? '',
      price: '${data['price'] ?? 0} บาท', // แปลงตัวเลขเป็น String + หน่วย
      location: data['location'] ?? 'ไม่ระบุสถานที่',
      imageUrl:
          data['imageUrl'] ??
          'https://via.placeholder.com/300x200.png?text=No+Image',
      createdBy: data['createdBy'] ?? '',
    );
  }
}
