// lib/models/user_model.dart

class UserProfile {
  String firstName;
  String lastName;
  String studentId;
  String faculty;
  String major;
  String year;
  String imageUrl;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.faculty,
    required this.major,
    required this.year,
    required this.imageUrl,
  });
}

// สร้างตัวแปร Global เพื่อเก็บข้อมูล User ปัจจุบัน (Mock Data)
UserProfile currentUser = UserProfile(
  firstName: 'นักศึกษา',
  lastName: 'ตัวอย่าง',
  studentId: '641234567',
  faculty: 'วิทยาการจัดการ',
  major: 'นิเทศศาสตร์',
  year: '3',
  imageUrl:
      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
);
