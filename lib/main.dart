import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // นำเข้าหน้า Home

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniJobs', // ชื่อแอป
      debugShowCheckedModeBanner: false, // ปิดป้าย Debug มุมขวาบน
      // การตั้งค่าธีม (Theme Setup)
      theme: ThemeData(
        useMaterial3: true, // เปิดใช้ Material 3 Design
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange, // กำหนดสีส้มเป็นสีหลัก (Primary Color)
          brightness: Brightness.light, // โหมดสว่าง
        ),
        // ปรับแต่ง AppBar ให้พื้นหลังเป็นสีส้มอ่อนๆ (optional)
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange.shade50,
          foregroundColor: Colors.orange.shade900, // สีตัวอักษรใน AppBar
        ),
      ),

      // หน้าแรกของแอป
      home: const HomeScreen(),
    );
  }
}
