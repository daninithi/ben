import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? id;
  String? text; // Changed from 'content' to 'text' to match Cloud Function
  String? senderId;
  String? receiverId;
  DateTime? timestamp;

  Message({
    this.id,
    this.text,
    this.senderId,
    this.receiverId,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text, // Changed from 'content' to 'text'
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] != null ? map['id'] as String : null,
      text: map['text'] != null ? map['text'] as String : null, // Changed from 'content'
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      receiverId: map['receiverId'] != null ? map['receiverId'] as String : null,
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate() 
          : null,
    );
  }
}