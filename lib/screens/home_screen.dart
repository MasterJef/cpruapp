import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. ต้อง Import ตัวนี้
import 'firebase_options.dart'; // 2. ต้อง Import ตัวนี้ (ที่ได้จากการ config)

import 'screens/home_screen.dart';
import 'screens/post_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';

// 3. เปลี่ยน void main() ธรรมดา ให้เป็น async
void main() async {
  // 4. ต้องใส่บรรทัดนี้ เพื่อให้ Flutter เตรียมตัวก่อนเริ่ม Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 5. สั่งเริ่มระบบ Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      // เช็คว่า User ล็อกอินค้างไว้ไหม (Optional: เดี๋ยวค่อยทำก็ได้ ตอนนี้เอาหน้า Login ก่อน)
      home: const LoginScreen(),
    );
  }
}

// ... (ส่วน MainNavigationWrapper ด้านล่างคงเดิมครับ) ...
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(), // ใช้หน้า History ที่แก้แล้ว (ดึงจาก Firebase)
    const ProfileScreen(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostSelectionScreen(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'ประวัติ',
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
