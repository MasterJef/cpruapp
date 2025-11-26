class UserProfile {
  String uid; // ✅ เพิ่ม ID (สำคัญเวลาจะแก้ไขข้อมูล)
  String email; // ✅ เพิ่ม Email (สำคัญเวลาโชว์หน้าโปรไฟล์)
  String firstName;
  String lastName;
  String studentId;
  String faculty;
  String major;
  String year;
  String imageUrl;

  UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.faculty,
    required this.major,
    required this.year,
    required this.imageUrl,
  });

  // (Optional) เผื่ออยากใช้ Factory แบบ Job/Freelancer ในอนาคต
  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      studentId: data['studentId'] ?? '',
      faculty: data['faculty'] ?? '',
      major: data['major'] ?? '',
      year: data['year'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

// 🔥 ตัวแปร Global (ต้องเพิ่ม uid กับ email ในค่าเริ่มต้นด้วย)
UserProfile currentUser = UserProfile(
  uid: '',
  email: '',
  firstName: '',
  lastName: '',
  studentId: '',
  faculty: '',
  major: '',
  year: '',
  imageUrl: '',
);
