import 'package:chat_app/core/services/database_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class FirebaseMessagingService {
  // Private constructor for singleton pattern
  FirebaseMessagingService._internal();

  // Singleton instance
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to the database service for saving tokens
  final DatabaseService _databaseService = DatabaseService();

  // Global navigator key for navigation
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize Firebase Messaging and sets up all message listeners
  Future<void> init() async {
    // Listen for authentication state changes to get the user UID
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        log('User authenticated. Initializing FCM.');
        // Handle FCM token after a user has signed in
        // Pass the user.uid to the handler function
        await _handlePushNotificationsToken(user.uid);
      } else {
        log('User is not authenticated. Skipping FCM token handling.');
      }
    });

    // Request user permission for notifications
    await _requestPermission();

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken(String userId) async {
    // Get the FCM token for the device
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      log('Push notifications token: $token');
      // Save the token to the current user's Firestore document
      await _databaseService.saveUserFcmToken(userId, token);
    } else {
      log('Failed to get FCM token.');
    }

    // Listen for token refresh events
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      log('FCM token refreshed: $fcmToken');
      // Update the token in Firestore for the current user
      await _databaseService.saveUserFcmToken(userId, fcmToken);
    }).onError((error) {
      // Handle errors during token refresh
      log('Error refreshing FCM token: $error');
    });
  }

  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    // Request permission for alerts, badges, and sounds
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Log the user's permission decision
    log('User granted permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  void _onForegroundMessage(RemoteMessage message) {
    log('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      // Handle foreground notification directly
      log('Notification title: ${notificationData.title}');
      log('Notification body: ${notificationData.body}');
      
      // Show in-app notification or handle as needed
      _showInAppNotification(message);
    }
  }

  /// Handles notification taps when app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    log('Notification caused the app to open: ${message.data.toString()}');
    
    // Handle navigation based on notification data
    final chatId = message.data['chatId'];
    final senderId = message.data['senderId'];
    
    if (chatId != null && senderId != null) {
      // Navigate to chat screen
      _navigateToChat(chatId, senderId);
    }
  }

  /// Show in-app notification when app is in foreground
  void _showInAppNotification(RemoteMessage message) {
    if (navigatorKey?.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey!.currentContext!).showSnackBar(
        SnackBar(
          content: Text('${message.notification?.title}: ${message.notification?.body}'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              final chatId = message.data['chatId'];
              final senderId = message.data['senderId'];
              if (chatId != null && senderId != null) {
                _navigateToChat(chatId, senderId);
              }
            },
          ),
        ),
      );
    }
  }

  /// Navigate to chat screen
  void _navigateToChat(String chatId, String senderId) {
    // You'll need to implement this based on your routing
    // This is just an example - adapt to your navigation structure
    if (navigatorKey?.currentContext != null) {
      // Example navigation - adapt this to your app's structure
      // Navigator.of(navigatorKey!.currentContext!).pushNamed(
      //   '/chat',
      //   arguments: {'chatId': chatId, 'senderId': senderId},
      // );
      log('Navigate to chat: $chatId with sender: $senderId');
    }
  }
}