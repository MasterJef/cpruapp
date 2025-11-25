// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/post_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/history_screen.dart'; // import หน้าประวัติ
import 'screens/profile_screen.dart'; // import หน้าโปรไฟล์

void main() {
  runApp(const UniJobsApp());
}

class UniJobsApp extends StatelessWidget {
  const UniJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniJobs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  // รายชื่อหน้าจอ (Tab)
  final List<Widget> _screens = [
    const HomeScreen(), // 0: หน้าหลัก
    const HistoryScreen(), // 1: หน้าประวัติการทำรายการ (แทนที่หน้าโพสต์เดิม)
    const ProfileScreen(), // 2: หน้าโปรไฟล์
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // ปุ่มวงกลมเครื่องหมายบวก มุมขวาล่าง
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // กดบวกแล้วเปิดหน้าเลือกโพสต์
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostSelectionScreen(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: const CircleBorder(), // ทำให้เป็นวงกลมแท้ๆ
        child: const Icon(Icons.add, size: 30),
      ),
      // ตำแหน่งปุ่ม FAB (วางไว้มุมขวาล่าง ใกล้ Footer)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Footer Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.orange.shade200,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined), // ไอคอนประวัติ
            selectedIcon: Icon(Icons.history),
            label: 'ประวัติ', // เปลี่ยนชื่อเป็น ประวัติ
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
