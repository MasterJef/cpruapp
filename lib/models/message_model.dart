import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  // แปลงจาก Map (Firebase) เป็น Object
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['text'] ?? '', // ใน Firestore field ชื่อ 'text'
      timestamp:
          map['createdAt'] ??
          Timestamp.now(), // ใน Firestore field ชื่อ 'createdAt'
    );
  }

  // แปลงจาก Object เป็น Map (เพื่อส่งขึ้น Firebase)
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': message,
      'createdAt': timestamp,
    };
  }
}
