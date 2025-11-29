import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // จำเป็นสำหรับ kIsWeb

// Import หน้าจอต่างๆ
import 'package:cprujobapp/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- ส่วนเชื่อมต่อ Firebase ---
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyADZx4zRveKQLg_ho1RBkGIp-L0xqXDpuM",
        authDomain: "cprujobapp.firebaseapp.com",
        projectId: "cprujobapp",
        storageBucket: "cprujobapp.firebasestorage.app",
        messagingSenderId: "417559432644",
        appId: "1:417559432644:web:9dfcd7fceb260d4ecf6891",
        measurementId: "G-9HS6ZY2G0Y",
      ),
    );
  } else {
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
      debugShowCheckedModeBanner: false,
      title: 'UniJobs',

      // --- ตั้งค่า Theme ใหม่ (แก้ไขแล้ว) ---
      theme: ThemeData(
        useMaterial3: true,
        // fontFamily: 'Sarabun', // เปิดใช้ถ้าลงฟอนต์แล้ว

        // 1. Color Palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE64A19), // Deep Orange
          primary: const Color(0xFFE64A19),
          secondary: const Color(0xFFFF8A65),
          surface: Colors.white,
          background: const Color(0xFFF8F9FA),
        ),

        // 2. Background Color
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),

        // 3. AppBar Style
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),

        // 5. Input Style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE64A19), width: 2),
          ),
        ),
      ),

      // หน้าแรก
      home: const LoginScreen(),
    );
  }
}
