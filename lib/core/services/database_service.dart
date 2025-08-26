import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;
  
  Future<void> saveUserFcmToken(String userId, String token) async {
    try {
      await _fire.collection('users').doc(userId).update({
        'fcmToken': token,
      });
      log("FCM token saved successfully for user: $userId");
    } catch (e) {
      log("Error saving FCM token: $e");
      // Fallback to set if the document doesn't exist yet
      try {
        await _fire.collection('users').doc(userId).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        log("FCM token saved successfully using set for user: $userId");
      } catch (e) {
        log("Error saving FCM token with set: $e");
        rethrow;
      }
    }
  }

  // Save a contact for a user
  Future<void> saveContact(
    String ownerUid,
    Map<String, dynamic> contactData,
  ) async {
    try {
      await _fire
          .collection('contacts')
          .doc(ownerUid)
          .collection('userContacts')
          .doc(contactData['uid'])
          .set(contactData);
      log("Contact saved for $ownerUid: ${contactData['uid']}");
    } catch (e) {
      rethrow;
    }
  }

  // Update contact request status
  Future<void> updateContactRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      await _fire.collection('contact_requests').doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Send a contact request
  Future<void> sendContactRequest({
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    try {
      await _fire.collection('contact_requests').add({
        'senderUid': senderUid,
        'senderName': senderName,
        'receiverUid': receiverUid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      log("Contact request sent from $senderUid to $receiverUid");
    } catch (e) {
      rethrow;
    }
  }

  // Listen for incoming contact requests for a user
  Stream<QuerySnapshot> listenContactRequests(String receiverUid) {
    return _fire
        .collection('contact_requests')
        .where('receiverUid', isEqualTo: receiverUid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _fire.collection('users').doc(userData['uid']).set(userData);
      log("user saved successfully: ${userData['uid']}");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUser(String uid) async {
    try {
      final res = await _fire.collection('users').doc(uid).get();
      if (res.data() != null) {
        log("user fetched successfully: $uid");
        return res.data() as Map<String, dynamic>;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchUsers(String currentUserId) async {
    try {
      final res = await _fire
          .collection("users")
          .where("uid", isNotEqualTo: currentUserId)
          .get();
    } catch (e) {
      log("Error fetching users: $e");
      rethrow;
    }
  }

  // Method to get all chat users for the current user (users with messages)
  Stream<QuerySnapshot> getChatUsers(String currentUserUid) {
    return _fire
        .collection('chats')
        .where('participants', arrayContains: currentUserUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Create an initial chat record between two users
  Future<void> createInitialChat(String user1Id, String user2Id) async {
    try {
      // Sort IDs to ensure consistent chat ID
      final List<String> sortedIds = [user1Id, user2Id]..sort();
      final String chatId = '${sortedIds[0]}_${sortedIds[1]}';

      // Create or update the chat document
      await _fire.collection('chats').doc(chatId).set({
        'participants': [user1Id, user2Id],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': null
      }, SetOptions(merge: true));

      log('Created initial chat between $user1Id and $user2Id');
    } catch (e) {
      log('Error creating initial chat: $e');
      rethrow;
    }
  }


  // New method to create a temporary chat
  Future<void> createTemporaryChat(String currentUserUid, String scannedUserUid) async {
    try {
      // Create a unique chat ID by combining and sorting the UIDs
      List<String> userUids = [currentUserUid, scannedUserUid];
      userUids.sort(); // Sort to ensure the chat ID is consistent regardless of who scanned whom
      String chatId = userUids.join('_');

      // Check if a chat already exists to avoid duplication
      DocumentSnapshot chatDoc = await _fire.collection('temporary_chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Create the new temporary chat document
        await _fire.collection('temporary_chats').doc(chatId).set({
          'participants': [currentUserUid, scannedUserUid],
          'lastMessage': '',
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        log('Temporary chat created with ID: $chatId');
      } else {
        log('Temporary chat with ID: $chatId already exists.');
      }
    } catch (e) {
      log('Error creating temporary chat: $e');
      rethrow; // Re-throw the error so it can be caught in the ViewModel
    }
  }

  // You will also need a method to get the current user's UID
  String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }


  // In your recent chats ViewModel or Page
  Stream<QuerySnapshot> getTemporaryChats(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('temporary_chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  
}
