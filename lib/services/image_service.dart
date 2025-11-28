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
        imageQuality: 70,
        maxWidth: 1024,
      );
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  // เลือกหลายรูป (New Feature)
  Future<List<XFile>> pickMultiImages() async {
    try {
      return await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1024);
    } catch (e) {
      debugPrint('Error picking multi images: $e');
      return [];
    }
  }

  Future<String?> uploadImage(XFile image, String folderPath) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      Reference ref = FirebaseStorage.instance.ref().child(
        '$folderPath/$fileName',
      );
      UploadTask task = kIsWeb
          ? ref.putData(await image.readAsBytes())
          : ref.putFile(File(image.path));
      TaskSnapshot snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload Error: $e');
      return null;
    }
  }

  // อัปโหลดหลายรูปพร้อมกัน (New Feature)
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
