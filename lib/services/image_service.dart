import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // สำหรับ kIsWeb

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ------------------------------------------
  // ส่วนที่ 1: สำหรับรูปเดียว (Single Image) - ใช้กับ Profile / Job
  // ------------------------------------------

  // 1.1 เลือกรูปเดียว
  Future<XFile?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (pickedFile != null) {
        return await _cropImage(pickedFile);
      }
      return null;
    } catch (e) {
      print('Pick Image Error: $e');
      return null;
    }
  }

  // 1.2 อัปโหลดรูปเดียว
  Future<String?> uploadImage(XFile image, String folderName) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      Reference ref = _storage.ref().child('$folderName/$fileName');

      if (kIsWeb) {
        var bytes = await image.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        File file = File(image.path);
        await ref.putFile(file);
      }

      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload Single Error: $e');
      return null;
    }
  }

  // ------------------------------------------
  // ส่วนที่ 2: สำหรับหลายรูป (Multiple Images) - ใช้กับ Product
  // ------------------------------------------

  // 2.1 เลือกหลายรูป (Multi Pick)
  Future<List<XFile>> pickMultiImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      // หมายเหตุ: pickMultiImage ปกติจะไม่รองรับ Crop ทีละรูป (มันจะยุ่งยาก)
      // ดังนั้นเราจะส่งรูปดิบไปเลย หรือถ้าอยาก Crop ต้องวนลูปเรียก _cropImage
      return pickedFiles;
    } catch (e) {
      print('Pick Multi Error: $e');
      return [];
    }
  }

  // 2.2 อัปโหลดหลายรูป (Multi Upload)
  Future<List<String>> uploadMultipleImages(
    List<XFile> images,
    String folderName,
  ) async {
    List<String> urls = [];
    try {
      for (var image in images) {
        String? url = await uploadImage(
          image,
          folderName,
        ); // เรียกใช้ฟังก์ชันเดี่ยวซ้ำๆ
        if (url != null) {
          urls.add(url);
        }
      }
    } catch (e) {
      print('Upload Multi Error: $e');
    }
    return urls;
  }

  // ------------------------------------------
  // Helper: Crop Image (ใช้ร่วมกัน)
  // ------------------------------------------
  Future<XFile?> _cropImage(XFile imageFile) async {
    try {
      if (kIsWeb) return imageFile; // เว็บไม่ Crop

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'จัดตำแหน่งรูปภาพ',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'จัดตำแหน่งรูปภาพ',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        return XFile(croppedFile.path);
      }
      return null;
    } catch (e) {
      print('Crop Error: $e');
      return imageFile;
    }
  }
}
