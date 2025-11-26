// lib/models/mock_data.dart

// --- ลบ Class Job ออก! เพราะเราใช้ lib/models/job_model.dart แล้ว ---
// --- ลบ mockJobs ออก! เพราะเราดึงจาก Firebase แล้ว ---

// --- เหลือไว้แค่ Freelancer (เพราะเรายังไม่มีระบบ Freelancer ใน Firebase) ---
class Freelancer {
  final String id;
  final String name;
  final String skill;
  final double rating;
  final String startingPrice;
  final String imageUrl;
  final String bio;
  final String type;

  Freelancer({
    required this.id,
    required this.name,
    required this.skill,
    required this.rating,
    required this.startingPrice,
    required this.imageUrl,
    required this.bio,
    this.type = 'person',
  });
}

// ยังจำเป็นต้องเก็บ list นี้ไว้ จนกว่าจะทำระบบ Freelancer ลง Firebase
List<Freelancer> mockFreelancers = [
  Freelancer(
    id: 'f1',
    name: 'น้องเอ รับหิ้ว',
    skill: 'Delivery',
    rating: 4.8,
    startingPrice: 'เริ่ม 10 บ.',
    imageUrl:
        'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
    bio: 'รับหิ้วโซนหอใน ทักได้ตลอด',
  ),
  // ... เพิ่มคนอื่นตามเดิม ...
];
