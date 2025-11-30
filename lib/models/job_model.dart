import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String price;
  final String location;
  final List<String> imageUrls;
  final String category; // ✅ เพิ่มตัวนี้ (สำคัญมากสำหรับ Filter)
  final String createdBy;
  final String authorName;
  final String authorAvatar;
  final String status;
  final String? acceptedBy;
  final DateTime? createdAt;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrls,
    required this.category, // ✅
    required this.createdBy,
    required this.authorName,
    required this.authorAvatar,
    required this.status,
    this.acceptedBy,
    this.createdAt,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Logic จัดการรูปภาพ (ของคุณเดิม ดีอยู่แล้วครับ)
    List<String> images = [];
    if (data['imageUrls'] != null) {
      images = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      images.add(data['imageUrl']);
    }

    // ถ้าไม่มีรูปเลย ให้ใส่ Placeholder
    if (images.isEmpty) {
      images.add('https://via.placeholder.com/300x200.png?text=No+Image');
    }

    return Job(
      id: doc.id,
      title: data['title'] ?? 'ไม่ระบุชื่อ',
      description: data['description'] ?? '',
      price: '${data['price'] ?? 0}',
      location: data['location'] ?? 'ไม่ระบุ',
      imageUrls: images,
      category:
          data['category'] ??
          'ทั่วไป', // ✅ ดึงหมวดหมู่ (ถ้าไม่มีให้เป็น 'ทั่วไป')
      createdBy: data['createdBy'] ?? '',
      authorName: data['authorName'] ?? 'ไม่ระบุตัวตน',
      authorAvatar:
          data['authorAvatar'] ??
          'https://cdn-icons-png.flaticon.com/512/149/149071.png',
      status: data['status'] ?? 'open',
      acceptedBy: data['acceptedBy'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
