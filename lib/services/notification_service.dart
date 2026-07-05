// =============================================================================
// NexaStays Notification Service
// =============================================================================
// Centralised manager for Firebase Cloud Messaging (FCM) push notifications.
// Handles permissions, token generation, background/foreground message routing,
// and topic subscriptions.
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ── Background Handler ──────────────────────────────────────────────────────
// Must be a top-level function outside of any class to run in isolated isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to initialize Firebase here, ensure you do it before handling the message.
  // await Firebase.initializeApp();
  if (kDebugMode) {
    print(
        '✅ [NotificationService] Background message received: ${message.messageId}');
  }
}

/// Service managing all push notification operations using [firebase_messaging].
class NotificationService {
  NotificationService() {
    // Register the background handler immediately
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// A broadcast stream of incoming messages while the app is in the foreground.
  /// UI components (like a globally stacked Toast listener) can listen to this.
  final StreamController<RemoteMessage> messageStream =
      StreamController<RemoteMessage>.broadcast();

  /// Initializes FCM, requests permissions, and sets up routing listeners.
  /// Should be called during app bootstrap (e.g., after Firebase.initializeApp()).
  Future<void> initialize() async {
    // 1. Request granular iOS/Android permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print(
          '🔔 [NotificationService] User granted permission: ${settings.authorizationStatus}');
    }

    // 2. Retrieve initial FCM Token
    final token = await getDeviceToken();
    if (kDebugMode) {
      print('🔔 [NotificationService] Initial FCM Token: $token');
    }

    // 3. Setup Listeners
    _setupMessageHandlers();
  }

  /// Registers listeners for Foreground, Background tap, and Terminated tap events.
  void _setupMessageHandlers() {
    // Fired when a message is received while the app is actively in the FOREGROUND.
    // DOES NOT show a system notification automatically on Android.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            '📨 [NotificationService] Foreground message: ${message.notification?.title}');
      }
      // Pipe it out so the UI can show an in-app toast/snackbar
      messageStream.add(message);
    });

    // Fired when the user taps on a notification to open the app from the BACKGROUND.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            '👆 [NotificationService] Notification tapped from background: $message');
      }
      _handleNotificationTap(message);
    });

    // Handle the scenario where the app was fully TERMINATED and launched by a tap.
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print(
              '🚀 [NotificationService] App launched from terminated state via tap.');
        }
        // Small delay to ensure the Router is fully mounted before attempting navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message);
        });
      }
    });
  }

  /// Routes the user to a specific screen based on the notification data payload.
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    // Example: { "type": "booking_update", "bookingId": "123" }
    // TODO: Wire this to your global navigator (e.g., go_router) via a global ref or contextless nav key.

    if (kDebugMode) {
      print(
          '🗺️ [NotificationService] Routing placeholder for data payload: $data');
    }
  }

  /// Retrieves the current unique Firebase Cloud Messaging token for this device.
  /// Typically sent to your backend `users` table to target this specific device.
  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [NotificationService] Failed to get device token: $e');
      }
      return null;
    }
  }

  /// Subscribes this device to a broadcast [topic].
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('📡 [NotificationService] Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [NotificationService] Topic subscription failed: $e');
      }
    }
  }

  /// Unsubscribes this device from a broadcast [topic].
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('🔇 [NotificationService] Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [NotificationService] Topic unsubscription failed: $e');
      }
    }
  }

  /// Clean up the stream controller when the service dies (rare for singletons,
  /// but good practice).
  void dispose() {
    messageStream.close();
  }
}
