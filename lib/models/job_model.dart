import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String price; // เก็บเป็นตัวเลขหรือข้อความตัวเลข เช่น "500"
  final String location;
  final List<String> imageUrls; // เปลี่ยนเป็น List
  final String createdBy;
  final String authorName; // เพิ่มชื่อคนโพสต์
  final String authorAvatar; // เพิ่มรูปคนโพสต์
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
    required this.createdBy,
    required this.authorName,
    required this.authorAvatar,
    required this.status,
    this.acceptedBy,
    this.createdAt,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Logic จัดการรูปภาพ (รองรับทั้งข้อมูลเก่าและใหม่)
    List<String> images = [];
    if (data['imageUrls'] != null) {
      images = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      // รองรับข้อมูลเก่าที่มีรูปเดียว
      images.add(data['imageUrl']);
    }
    if (images.isEmpty) {
      images.add('https://via.placeholder.com/300x200.png?text=No+Image');
    }

    return Job(
      id: doc.id,
      title: data['title'] ?? 'ไม่ระบุชื่อ',
      description: data['description'] ?? '',
      price:
          '${data['price'] ?? 0}', // ดึงมาแค่ตัวเลข/ข้อความ ไม่เติม "บาท" ที่นี่
      location: data['location'] ?? 'ไม่ระบุ',
      imageUrls: images,
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
