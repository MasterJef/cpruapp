class UserProfile {
  String uid; // ✅ เพิ่มแล้ว
  String email; // ✅ เพิ่มแล้ว
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
}

// 🔥 ตัวแปร Global: ประกาศไว้ตรงนี้ที่เดียว เรียกใช้ได้ทั้งแอพ
UserProfile currentUser = UserProfile(
  uid: '', // ✅ ใส่ค่าเริ่มต้น
  email: '', // ✅ ใส่ค่าเริ่มต้น
  firstName: '',
  lastName: '',
  studentId: '',
  faculty: '',
  major: '',
  year: '',
  imageUrl: '',
);
