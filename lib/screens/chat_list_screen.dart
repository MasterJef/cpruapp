import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // import intl
import '../services/chat_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ข้อความ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getUserChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('เกิดข้อผิดพลาด'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีการสนทนา',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var roomData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // หา UID ของคู่สนทนา (คือ ID ใน array users ที่ไม่ใช่ของเรา)
              List<dynamic> users = roomData['users'];
              String otherUserId = users.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              // ดึงข้อมูล User ฝั่งตรงข้าม (ชื่อ/รูป)
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData)
                    return const SizedBox(); // กำลังโหลดข้อมูล user

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData == null) return const SizedBox(); // ไม่พบ user

                  String name =
                      '${userData['firstName']} ${userData['lastName']}';
                  String imageUrl =
                      userData['imageUrl'] ?? 'https://via.placeholder.com/150';
                  String lastMessage = roomData['lastMessage'] ?? '';
                  Timestamp lastTime = roomData['lastTime'];
                  String timeFormatted = DateFormat(
                    'dd/MM HH:mm',
                  ).format(lastTime.toDate());

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 25,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        timeFormatted,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        // กดแล้วไปหน้าแชท
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              targetUserId: otherUserId,
                              targetUserName: name,
                              targetUserImage: imageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
