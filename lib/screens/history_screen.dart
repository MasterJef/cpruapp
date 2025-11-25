// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../models/mock_data.dart'; // ดึงข้อมูล mock มาแสดง

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ประวัติการทำรายการ'),
          automaticallyImplyLeading:
              false, // ไม่โชว์ปุ่ม Back เพราะอยู่ใน TabBar หลัก
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'ประวัติการโพสต์'),
              Tab(text: 'ประวัติการใช้บริการ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildPostHistory(), _buildServiceHistory()],
        ),
      ),
    );
  }

  // Tab 1: งานที่เราเคยโพสต์หาคน
  Widget _buildPostHistory() {
    return ListView.builder(
      itemCount: mockJobs.length, // ใช้ข้อมูล mock เดิมไปก่อน
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final job = mockJobs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.campaign, color: Colors.white),
            ),
            title: Text(
              job.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'สถานะ: กำลังหาคน\nวันที่ลง: 25 พ.ย. 66',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  // Tab 2: บริการที่เราเคยไปจ้างเขา
  Widget _buildServiceHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีประวัติการจ้างงาน',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
