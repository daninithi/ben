import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get messages stream for a chat room
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Save message to the correct path that matches Cloud Function
  Future<void> saveMessage(Map<String, dynamic> messageData, String chatRoomId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);
      
      // Also update the chat room's last message info
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .set({
        'lastMessage': messageData['text'],
        'lastMessageTime': messageData['timestamp'],
        'participants': [messageData['senderId'], messageData['receiverId']],
      }, SetOptions(merge: true));
      
      log("Message saved successfully to chatRooms/$chatRoomId/messages");
    } catch (e) {
      log("Error saving message: $e");
      rethrow;
    }
  }

  // Update last message info
  Future<void> updateLastMessage(
    String senderId,
    String receiverId,
    String lastMessage,
    int timestamp,
  ) async {
    try {
      List<String> ids = [senderId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");
      
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': lastMessage,
        'lastMessageTime': timestamp,
      });
    } catch (e) {
      log("Error updating last message: $e");
      rethrow;
    }
  }
}