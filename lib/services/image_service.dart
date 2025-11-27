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
        imageQuality: 50, // บีบอัดรูป
        maxWidth: 800, // จำกัดขนาด
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // 2. ฟังก์ชันอัปโหลดรูป (รองรับทั้ง Web และ Mobile)
  // ... (โค้ดส่วนบนเหมือนเดิม)

  Future<String?> uploadImage(XFile image, String folderPath) async {
    try {
      print('--- START UPLOAD ---'); // 1. เริ่มทำงานไหม
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(
        '$folderPath/$fileName',
      );

      UploadTask uploadTask;

      if (kIsWeb) {
        print('--- Mode: WEB ---');
        final bytes = await image.readAsBytes();
        print(
          '--- Read Bytes Done (${bytes.length} bytes) ---',
        ); // 2. อ่านไฟล์เสร็จไหม
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        print('--- Mode: MOBILE ---');
        File ioFile = File(image.path);
        uploadTask = ref.putFile(ioFile);
      }

      print('--- Uploading... (Waiting) ---'); // 3. กำลังส่งข้อมูล

      // เพิ่ม Listener เพื่อดู % การอัปโหลด
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload is $progress% done');
      });

      TaskSnapshot snapshot = await uploadTask;
      print('--- Upload Done! ---'); // 4. อัปโหลดเสร็จ

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('--- Got URL: $downloadUrl ---'); // 5. ได้ URL

      return downloadUrl;
    } catch (e) {
      print('!!! ERROR UPLOADING: $e'); // ถ้า Error จะโชว์ตรงนี้
      return null;
    }
  }
}
