import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // จำเป็นสำหรับ kIsWeb

// Import หน้าจอต่างๆ (เช็คชื่อโฟลเดอร์ให้ตรงนะครับ)
import 'package:cprujobapp/screens/login_screen.dart';
// import 'package:cprujobapp/screens/home_screen.dart'; // เปิดใช้อันนี้ถ้าอยากข้ามหน้า Login ไปเทส

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- ส่วนเชื่อมต่อ Firebase ---
  if (kIsWeb) {
    // กรณีรันบนเว็บ (Chrome)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // ⚠️ เอาค่าจากหน้าเว็บ Firebase ของคุณมาใส่ตรงนี้นะครับ (ก๊อปจากที่เคยทำตะกี้)
        apiKey: "AIzaSyADZx4zRvkQLg_ho1RBKGnP-L0xqXDpuM",
        authDomain: "cprujobapp.firebaseapp.com",
        projectId: "cprujobapp",
        storageBucket: "cprujobapp.firebasestorage.app",
        messagingSenderId: "417559432644",
        appId: "1:417559432644:web:9dfcd7fceb260d4ecf6891",
        measurementId: "G-9HS6ZY2G0Y",
      ),
    );
  } else {
    // กรณีรันบนมือถือ (Android/iOS) มันจะอ่านไฟล์ google-services.json เอง
    await Firebase.initializeApp();
  }
  // ---------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดป้าย Debug มุมขวาบน
      title: 'UniJobs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00), // สีส้มธีมหลัก
          primary: const Color(0xFFFF6B00),
        ),
        useMaterial3: true,
        fontFamily: 'Sarabun', // (ถ้ามีฟอนต์) หรือลบออกถ้าไม่มี
      ),
      // 👇 กำหนดหน้าแรกของแอพตรงนี้
      home: const LoginScreen(),
    );
  }
}
