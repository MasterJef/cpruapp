import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart'; // ✅ Import ให้ถูก

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. สมัครสมาชิก + บันทึกข้อมูลลง Firestore
  Future<String?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required String faculty,
    required String major,
    required String year,
  }) async {
    try {
      // 1.1 สร้าง User ใน Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = cred.user!.uid;
      // แก้บรรทัดนี้
      String defaultImage =
          'https://cdn-icons-png.flaticon.com/512/149/149071.png';

      // 1.2 เตรียมข้อมูล User (✅ แก้ตรงนี้: ใส่ uid และ email)
      UserProfile newUser = UserProfile(
        uid: uid, // <--- ใส่ค่าที่ได้จาก Auth
        email: email, // <--- ใส่ค่า email
        firstName: firstName,
        lastName: lastName,
        studentId: studentId,
        faculty: faculty,
        major: major,
        year: year,
        imageUrl: defaultImage,
      );

      // 1.3 บันทึกลง Firestore
      await _db.collection('users').doc(uid).set({
        'uid': uid, // บันทึกลง DB ด้วย
        'firstName': firstName,
        'lastName': lastName,
        'studentId': studentId,
        'faculty': faculty,
        'major': major,
        'year': year,
        'imageUrl': defaultImage,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 1.4 อัปเดต Global Variable
      currentUser = newUser;

      return null;
    } on FirebaseAuthException catch (e) {
      // 👇 เพิ่มบรรทัดนี้เพื่อดู Code Error ใน Terminal
      print('🔥 Firebase Auth Error: code=${e.code}, message=${e.message}');

      if (e.code == 'weak-password') {
        return 'รหัสผ่านง่ายเกินไป (ต้อง 6 ตัวขึ้นไป)';
      } else if (e.code == 'email-already-in-use') {
        return 'อีเมลนี้มีคนใช้แล้ว';
      } else if (e.code == 'invalid-email') {
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      }
      return e.message; // ส่งข้อความ Error เดิมกลับไป
    } catch (e) {
      print('🔥 General Error: $e'); // ปริ้น Error ทั่วไปดูด้วย
      return 'เกิดข้อผิดพลาด: $e';
    }
  }

  // 2. ล็อกอิน + ดึงข้อมูล
  Future<String?> login(String email, String password) async {
    try {
      // 2.1 ล็อกอิน
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2.2 ดึงข้อมูลจาก Firestore
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // ✅ แก้ตรงนี้: อัปเดต Global Variable ให้ครบถ้วน
        currentUser = UserProfile(
          uid: cred.user!.uid, // <--- ดึงจาก Auth
          email: email, // <--- ดึงจากที่กรอก หรือ data['email']
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          studentId: data['studentId'] ?? '',
          faculty: data['faculty'] ?? '',
          major: data['major'] ?? '',
          year: data['year'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // 3. อัปโหลดรูป (เหมือนเดิม)
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      if (_auth.currentUser == null) return null;

      String uid = _auth.currentUser!.uid;
      Reference ref = _storage
          .ref()
          .child('profile_images')
          .child('profile_$uid.jpg');

      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();

      await _db.collection('users').doc(uid).update({'imageUrl': downloadUrl});

      // อัปเดต Global
      currentUser.imageUrl = downloadUrl;

      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // ควรเคลียร์ข้อมูล currentUser ด้วย
    currentUser = UserProfile(
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
  }
}
