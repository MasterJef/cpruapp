// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import '../widgets/responsive_layout.dart'; // Import Responsive

class ChatRoomScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String targetUserImage;

  const ChatRoomScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetUserImage,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(
        widget.targetUserId,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ ResponsiveContainer ครอบทั้งหน้า (รวม AppBar)
    // แต่เพื่อให้ AppBar สวยงาม เราจะครอบที่ Body หรือสร้าง Scaffold ซ้อน
    // วิธีที่ดีที่สุดสำหรับ Web App คือให้ Scaffold หลักอยู่ที่นี่ แล้วครอบ Body

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6), // สีพื้นหลังห้องแชท
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUserImage),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.targetUserName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      // ครอบ ResponsiveContainer ที่นี่
      body: ResponsiveContainer(
        child: Column(
          children: [
            // --- Message List ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatService.getMessages(
                  _auth.currentUser!.uid,
                  widget.targetUserId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(child: Text('เกิดข้อผิดพลาด'));
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  var docs = snapshot.data!.docs.reversed.toList();

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return _buildModernMessageItem(docs[index]);
                    },
                  );
                },
              ),
            ),

            // --- Floating Input Bar ---
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.transparent, // โปร่งใสเพื่อให้เห็นพื้นหลัง
                child: Row(
                  children: [
                    // ปุ่มเพิ่มรูป (Mock)
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                    // ช่องพิมพ์ข้อความ
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'พิมพ์ข้อความ...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ปุ่มส่ง
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สร้าง Bubble ข้อความแบบ Modern
  Widget _buildModernMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == _auth.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxWidth: 250,
            ), // จำกัดความกว้างข้อความ
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // ไล่สีสำหรับข้อความเรา / สีขาวสำหรับเขา
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    )
                  : null,
              color: isMe ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              data['text'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              DateFormat(
                'HH:mm',
              ).format((data['createdAt'] as Timestamp).toDate()),
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
