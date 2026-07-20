import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('[NotificationService] Background message: ${message.messageId}');
  }
}

/// FCM push notification manager.
class NotificationService {
  NotificationService() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<RemoteMessage> messageStream =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await getDeviceToken();
    if (kDebugMode && token != null) {
      print('[NotificationService] FCM token acquired');
    }

    _messaging.onTokenRefresh.listen(_tokenRefreshController.add);
    _setupMessageHandlers();
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(messageStream.add);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message);
        });
      }
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('[NotificationService] Tap payload: ${message.data}');
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] getToken failed: $e');
      }
      return null;
    }
  }

  void dispose() {
    messageStream.close();
    _tokenRefreshController.close();
  }
}
