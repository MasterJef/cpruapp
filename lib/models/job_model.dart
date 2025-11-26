import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String description;
  final String price;
  final String location;
  final String imageUrl;
  final String createdBy;
  // 👇 เพิ่ม 2 ตัวนี้เพื่อให้โค้ดไม่ Error
  final String category;
  final String type;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.createdBy,
    required this.category, // ✅ ต้องมี this.
    required this.type, // ✅ ต้องมี this.
  });

  // Factory Constructor: แปลงข้อมูลจาก Firebase มาเป็น Job Object
  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Job(
      id: doc.id,
      title: data['title'] ?? 'ไม่ระบุชื่องาน',
      description: data['description'] ?? '',
      // ⚠️ แนะนำ: ให้เก็บแค่ตัวเลข (เช่น "100") อย่าเพิ่งใส่คำว่า "บาท" ในนี้
      // เพราะหน้า Home เราใส่เครื่องหมาย ฿ ไว้แล้ว เดี๋ยวจะกลายเป็น "฿100 บาท" (ซ้ำ)
      price: (data['price'] ?? 0).toString(),
      location: data['location'] ?? 'ไม่ระบุสถานที่',
      imageUrl:
          data['imageUrl'] ??
          'https://via.placeholder.com/300x200.png?text=No+Image',
      createdBy: data['createdBy'] ?? '',
      // 👇 ดึงข้อมูล category และ type มาด้วย (ถ้าไม่มีให้ใส่ค่า Default)
      category: data['category'] ?? 'General',
      type: data['type'] ?? 'job',
    );
  }
}
