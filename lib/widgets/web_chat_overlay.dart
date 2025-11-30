import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';

// --- Widget หลักสำหรับจัดการ Chat Overlay ทั้งหมด ---
class WebChatOverlay extends StatelessWidget {
  final bool showDropdown;
  final Map<String, dynamic>?
  activeChatTarget; // ข้อมูลคนที่กำลังคุยด้วย (ถ้ามี)
  final bool isMinimized;
  final Function(Map<String, dynamic>) onChatSelected;
  final VoidCallback onCloseChat;
  final VoidCallback onMinimizeChat;

  const WebChatOverlay({
    super.key,
    required this.showDropdown,
    required this.activeChatTarget,
    required this.isMinimized,
    required this.onChatSelected,
    required this.onCloseChat,
    required this.onMinimizeChat,
  });

  @override
  Widget build(BuildContext context) {
    // ใช้ Stack เพื่อวางตำแหน่ง Dropdown และ Chat Window
    return Stack(
      children: [
        // 1. Dropdown รายชื่อแชท (แสดงเมื่อกดไอคอนแชท)
        if (showDropdown)
          Positioned(
            top: 5,
            right: 60, // ขยับซ้ายมาจากปุ่ม Profile นิดหน่อย
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 350,
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'แชทล่าสุด',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ChatListWidget(onChatSelected: onChatSelected),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 2. หน้าต่างแชทลอย (Floating Window)
        if (activeChatTarget != null)
          Positioned(
            bottom: 0,
            left: 20, // ห่างจากขอบขวา
            child: Material(
              elevation: 10,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                width: 320,
                height: isMinimized ? 50 : 450, // ย่อ/ขยาย ความสูง
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    // Header ของหน้าต่างแชท
                    GestureDetector(
                      onTap: onMinimizeChat, // กดที่หัวเพื่อย่อ/ขยาย
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                activeChatTarget!['image'],
                              ),
                              radius: 14,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activeChatTarget!['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isMinimized ? Icons.expand_less : Icons.remove,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onMinimizeChat,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onCloseChat,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Body ของหน้าต่างแชท (ซ่อนถ้าย่ออยู่)
                    if (!isMinimized)
                      Expanded(
                        child: MiniChatRoom(
                          targetUserId: activeChatTarget!['uid'],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// --- Widget ย่อย: รายการแชท (Reused logic from ChatListScreen) ---
class ChatListWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) onChatSelected;
  const ChatListWidget({super.key, required this.onChatSelected});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: ChatService().getUserChatRooms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('ยังไม่มีการสนทนา'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            List<dynamic> users = data['users'];
            String otherId = users.firstWhere(
              (id) => id != uid,
              orElse: () => '',
            );

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherId)
                  .get(),
              builder: (ctx, userSnap) {
                if (!userSnap.hasData) return const SizedBox();
                var userData = userSnap.data!.data() as Map<String, dynamic>;

                // ตรวจสอบว่าอ่านหรือยัง
                bool isRead = true;
                if (data['readBy'] != null && data['readBy'][uid] == false) {
                  isRead = false;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['imageUrl'] ?? ''),
                  ),
                  title: Text(
                    '${userData['firstName']} ${userData['lastName']}',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['lastMessage'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isRead ? Colors.grey : Colors.black87,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // ส่งข้อมูลกลับไปให้ HomeScreen เปิดหน้าต่าง
                    onChatSelected({
                      'uid': otherId,
                      'name':
                          '${userData['firstName']} ${userData['lastName']}',
                      'image': userData['imageUrl'] ?? '',
                    });
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- Widget ย่อย: ห้องแชทขนาดเล็ก (Mini Chat) ---
class MiniChatRoom extends StatefulWidget {
  final String targetUserId;
  const MiniChatRoom({super.key, required this.targetUserId});

  @override
  State<MiniChatRoom> createState() => _MiniChatRoomState();
}

class _MiniChatRoomState extends State<MiniChatRoom> {
  final _msgCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _send() {
    if (_msgCtrl.text.trim().isNotEmpty) {
      ChatService().sendMessage(widget.targetUserId, _msgCtrl.text.trim());
      _msgCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: ChatService().getMessages(
              _auth.currentUser!.uid,
              widget.targetUserId,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs.reversed.toList();

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  bool isMe = data['senderId'] == _auth.currentUser!.uid;
                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.orange : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        data['text'],
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Input
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Aa',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.orange, size: 20),
                onPressed: _send,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
