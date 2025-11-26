// lib/services/auth_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart'; // เพื่ออัปเดตตัวแปร Global

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

      // 1.2 เตรียมข้อมูล User
      String uid = cred.user!.uid;
      String defaultImage =
          'https://firebasestorage.googleapis.com/v0/b/placeholder.appspot.com/o/default_profile.png?alt=media'; // ใส่ URL รูป default ที่มีอยู่จริง หรือใช้ mock ไปก่อน

      UserProfile newUser = UserProfile(
        firstName: firstName,
        lastName: lastName,
        studentId: studentId,
        faculty: faculty,
        major: major,
        year: year,
        imageUrl: defaultImage, // เริ่มต้นใช้รูป Default
      );

      // 1.3 บันทึกลง Firestore Collection 'users'
      await _db.collection('users').doc(uid).set({
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

      // 1.4 อัปเดต Global Variable ในแอป
      currentUser = newUser;

      return null; // ไม่มี Error
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'เกิดข้อผิดพลาด: $e';
    }
  }

  // 2. ล็อกอิน + ดึงข้อมูล User จาก Firestore
  Future<String?> login(String email, String password) async {
    try {
      // 2.1 ล็อกอิน
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2.2 ดึงข้อมูล User Profile จาก Firestore
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // อัปเดต Global Variable
        currentUser = UserProfile(
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          studentId: data['studentId'] ?? '',
          faculty: data['faculty'] ?? '',
          major: data['major'] ?? '',
          year: data['year'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }
      return null; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // 3. อัปโหลดรูปโปรไฟล์
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      String uid = _auth.currentUser!.uid;
      // ตั้งชื่อไฟล์เป็น profile_UID.jpg
      Reference ref = _storage
          .ref()
          .child('profile_images')
          .child('profile_$uid.jpg');

      // อัปโหลด
      await ref.putFile(imageFile);

      // ขอ URL
      String downloadUrl = await ref.getDownloadURL();

      // อัปเดตใน Firestore
      await _db.collection('users').doc(uid).update({'imageUrl': downloadUrl});

      // อัปเดต Global
      currentUser.imageUrl = downloadUrl;

      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // 4. ออกจากระบบ
  Future<void> logout() async {
    await _auth.signOut();
  }
}
