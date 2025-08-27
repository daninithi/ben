import 'package:chat_app/core/services/database_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  final DatabaseService _databaseService = DatabaseService();
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize Firebase Messaging
  Future<void> init() async {
    log('Initializing Firebase Messaging Service');
    
    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        log('User authenticated. Initializing FCM for user: ${user.uid}');
        await _handlePushNotificationsToken(user.uid);
      } else {
        log('User is not authenticated. Skipping FCM token handling.');
      }
    });

    // Request user permission for notifications
    await _requestPermission();

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log('App opened from terminated state with message: ${initialMessage.data}');
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Get and save FCM token
  Future<void> _handlePushNotificationsToken(String userId) async {
    try {
      // Get the FCM token for the device
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log('FCM Token obtained: ${token.substring(0, 20)}...');
        await _databaseService.saveUserFcmToken(userId, token);
        log('FCM token saved for user: $userId');
      } else {
        log('Failed to get FCM token');
      }

      // Listen for token refresh events
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
        log('FCM token refreshed: ${fcmToken.substring(0, 20)}...');
        await _databaseService.saveUserFcmToken(userId, fcmToken);
      }).onError((error) {
        log('Error refreshing FCM token: $error');
      });
    } catch (e) {
      log('Error handling FCM token: $e');
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    try {
      final result = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      log('Notification permission status: ${result.authorizationStatus}');
      
      if (result.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted notification permissions');
      } else if (result.authorizationStatus == AuthorizationStatus.provisional) {
        log('User granted provisional notification permissions');
      } else {
        log('User declined or has not accepted notification permissions');
      }
    } catch (e) {
      log('Error requesting notification permission: $e');
    }
  }

  /// Handle foreground messages
  void _onForegroundMessage(RemoteMessage message) {
    log('Foreground message received');
    log('Message data: ${message.data}');
    log('Notification: ${message.notification?.title} - ${message.notification?.body}');
    
    final notificationData = message.notification;
    if (notificationData != null) {
      _showInAppNotification(message);
    }
  }

  /// Handle notification taps
  void _onMessageOpenedApp(RemoteMessage message) {
    log('Notification opened app');
    log('Message data: ${message.data}');
    
    final chatId = message.data['chatId'];
    final senderId = message.data['senderId'];
    
    if (chatId != null && senderId != null) {
      _navigateToChat(chatId, senderId);
    }
  }

  /// Show in-app notification
  void _showInAppNotification(RemoteMessage message) {
    if (navigatorKey?.currentContext != null) {
      final context = navigatorKey!.currentContext!;
      
      /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.notification?.title ?? 'New Message',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(message.notification?.body ?? ''),
            ],
          ),
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
          duration: const Duration(seconds: 4),
        ),
      ); */
    }
  }

  /// Navigate to chat screen
  void _navigateToChat(String chatId, String senderId) {
    log('Navigate to chat: $chatId with sender: $senderId');
    // Implement navigation logic based on your app structure
    if (navigatorKey?.currentContext != null) {
      // Example: You might want to navigate to chat screen here
      // Navigator.of(navigatorKey!.currentContext!).pushNamed(
      //   '/chat',
      //   arguments: {'chatId': chatId, 'senderId': senderId},
      // );
    }
  }
}