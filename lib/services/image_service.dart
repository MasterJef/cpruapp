// lib/services/image_service.dart
import 'dart:io'; // สำหรับ File บน Mobile
import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb
import 'package:image_picker/image_picker.dart'; // ต้องมี package นี้
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // 1. ฟังก์ชันเลือกรูป (คืนค่าเป็น XFile)
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // บีบอัดรูป
        maxWidth: 1024, // จำกัดขนาด
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // 2. ฟังก์ชันอัปโหลดรูป (รองรับทั้ง Web และ Mobile)
  Future<String?> uploadImage(XFile image, String folderPath) async {
    try {
      // สร้างชื่อไฟล์ไม่ซ้ำกัน
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(
        '$folderPath/$fileName',
      );

      UploadTask uploadTask;

      if (kIsWeb) {
        // --- สำหรับ WEB: อัปโหลดด้วย Bytes (Data) ---
        // XFile บนเว็บอ่านเป็น bytes ได้เลย
        final bytes = await image.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // --- สำหรับ MOBILE: อัปโหลดด้วย File ---
        // แปลง XFile path เป็น File ของ dart:io
        File ioFile = File(image.path);
        uploadTask = ref.putFile(ioFile);
      }

      // รอจนเสร็จแล้วขอ URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
