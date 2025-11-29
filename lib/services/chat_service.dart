import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return '${user1}_$user2';
    } else {
      return '${user2}_$user1';
    }
  }

  // 2. ส่งข้อความ
  Future<void> sendMessage(String receiverId, String messageText) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // สร้าง ID ห้อง
    String chatRoomId = getChatRoomId(currentUserId, receiverId);

    // สร้าง Object ข้อความ
    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      message: messageText,
      timestamp: timestamp,
    );

    // A. บันทึกข้อความลง Sub-collection 'messages'
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    // B. อัปเดตข้อมูลห้องแชท (เพื่อให้โชว์ในหน้ารวมแชทได้ทันที)
    await _firestore.collection('chat_rooms').doc(chatRoomId).set(
      {
        'users': [
          currentUserId,
          receiverId,
        ], // เก็บ array เพื่อ query ว่าเราอยู่ห้องไหนบ้าง
        'lastMessage': messageText,
        'lastTime': timestamp,
        'readBy': {
          currentUserId: true,
          receiverId:
              false, // ฝั่งตรงข้ามยังไม่ได้อ่าน (เผื่อทำระบบ Unread count)
        },
      },
      SetOptions(merge: true),
    ); // merge=true คือถ้ามีอยู่แล้วให้อัปเดต ถ้าไม่มีให้สร้างใหม่
  }

  // 3. ดึงข้อความในห้อง (Stream)
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    String chatRoomId = getChatRoomId(userId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false) // เรียงเก่าไปใหม่
        .snapshots();
  }

  // 4. ดึงรายการห้องแชทที่ตัวเองอยู่
  Stream<QuerySnapshot> getUserChatRooms() {
    final String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastTime', descending: true) // เรียงตามเวลาล่าสุด
        .snapshots();
  }
}
