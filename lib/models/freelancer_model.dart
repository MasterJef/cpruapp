import 'package:cloud_firestore/cloud_firestore.dart';

class Freelancer {
  final String id;
  final String name;
  final String skill;
  final double rating;
  final String imageUrl;
  final String bio;
  final String startingPrice; // ✅ ตัวนี้แหละที่ขาดไป

  Freelancer({
    required this.id,
    required this.name,
    required this.skill,
    required this.rating,
    required this.imageUrl,
    required this.bio,
    required this.startingPrice, // ✅ เพิ่มตรงนี้
  });

  factory Freelancer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Freelancer(
      id: doc.id,
      name: data['name'] ?? 'ไม่ระบุชื่อ',
      skill: data['skill'] ?? 'งานทั่วไป',
      rating: (data['rating'] is String)
          ? double.tryParse(data['rating']) ?? 0.0
          : (data['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      bio: data['bio'] ?? 'ไม่มีข้อมูลแนะนำตัว',
      // ✅ ถ้าใน Database ไม่มี field นี้ ให้ใช้ค่าเริ่มต้นว่า 'ตกลงกันได้'
      startingPrice: data['startingPrice'] ?? 'ตกลงกันได้',
    );
  }
}
