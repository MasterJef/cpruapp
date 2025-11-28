import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // เลือกรูปเดียว
  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // ปรับตาม Request: กว้างสูงสุด 800px
        imageQuality: 70, // ปรับตาม Request: คุณภาพ 70%
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // เลือกหลายรูป
  Future<List<XFile>> pickMultiImages() async {
    try {
      return await _picker.pickMultiImage(maxWidth: 800, imageQuality: 70);
    } catch (e) {
      debugPrint('Error picking multi images: $e');
      return [];
    }
  }

  // อัปโหลดรูปเดียว
  Future<String?> uploadImage(XFile image, String folderPath) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      Reference ref = FirebaseStorage.instance.ref().child(
        '$folderPath/$fileName',
      );

      UploadTask task;
      if (kIsWeb) {
        task = ref.putData(
          await image.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        task = ref.putFile(File(image.path));
      }

      TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload Error: $e');
      return null;
    }
  }

  // อัปโหลดหลายรูป
  Future<List<String>> uploadMultipleImages(
    List<XFile> images,
    String folderPath,
  ) async {
    List<String> urls = [];
    for (var image in images) {
      String? url = await uploadImage(image, folderPath);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}
