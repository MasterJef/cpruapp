import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // อย่าลืม import intl
import '../services/chat_service.dart';

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

  // ส่งข้อความ
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.targetUserId,
        _messageController.text,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ส่วนแสดงรายการข้อความ
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

                // Auto Scroll: ใช้ ListView reverse=true เพื่อให้ข้อความใหม่อยู่ล่างสุดเสมอ
                var docs = snapshot.data!.docs.reversed.toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    return _buildMessageItem(docs[index]);
                  },
                );
              },
            ),
          ),

          // ส่วนพิมพ์ข้อความ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // ตรวจสอบว่าเป็นข้อความของเราหรือไม่
    bool isMe = data['senderId'] == _auth.currentUser!.uid;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.orange : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              data['text'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'HH:mm',
              ).format((data['createdAt'] as Timestamp).toDate()),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
