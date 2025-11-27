// lib/services/image_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  // 1. ฟังก์ชันเลือกรูปจาก Gallery
  static Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // ลดคุณภาพเหลือ 70% เพื่อประหยัดเน็ตและพื้นที่
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // 2. ฟังก์ชันอัปโหลดรูปขึ้น Firebase Storage
  // pathFolder: เช่น 'job_images' หรือ 'profile_images'
  static Future<String?> uploadImage(File imageFile, String pathFolder) async {
    try {
      // สร้างชื่อไฟล์ไม่ซ้ำกันด้วย Timestamp
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // สร้าง Reference ไปยังตำแหน่งที่จะเก็บ
      Reference ref = FirebaseStorage.instance.ref().child(
        '$pathFolder/$fileName',
      );

      // เริ่มอัปโหลด
      UploadTask uploadTask = ref.putFile(imageFile);

      // รอจนเสร็จ
      TaskSnapshot snapshot = await uploadTask;

      // ขอ URL สำหรับดาวน์โหลดกลับมา
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
