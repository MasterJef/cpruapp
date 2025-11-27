// lib/services/image_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  // ตัวอย่าง ImageService.uploadImage ที่รองรับ Web
  static Future<String?> uploadImage(XFile imageFile, String pathFolder) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(
        '$pathFolder/$fileName',
      );

      // Upload logic ที่รองรับทั้ง Web และ Mobile
      if (kIsWeb) {
        // สำหรับ Web ให้อัปโหลดเป็น Bytes
        await ref.putData(await imageFile.readAsBytes());
      } else {
        // สำหรับ Mobile ให้อัปโหลดเป็น File
        await ref.putFile(File(imageFile.path));
      }

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
}
