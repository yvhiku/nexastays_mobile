import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_routes.dart';

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

  GoRouter? _router;

  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  /// Bind after [GoRouter] is created (see [NexaStaysApp]).
  void bindRouter(GoRouter router) {
    _router = router;
  }

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

    final router = _router;
    if (router == null) return;

    final data = message.data;
    final actionUrl = data['action_url'] as String?;
    final conversationId = data['conversation_id'] as String?;
    final lastMessageId = data['last_message_id'] as String?;
    final conversationVersionRaw = data['conversation_version'];
    final conversationVersion = conversationVersionRaw != null
        ? int.tryParse(conversationVersionRaw.toString())
        : null;

    String? targetConversationId = conversationId;
    if (targetConversationId == null && actionUrl != null) {
      final match = RegExp(r'^/inbox/([^/?#]+)').firstMatch(actionUrl);
      targetConversationId = match?.group(1);
    }

    if (targetConversationId == null || targetConversationId.isEmpty) {
      if (actionUrl == AppRoutes.inbox || actionUrl?.endsWith('/inbox') == true) {
        router.push(AppRoutes.inbox);
      }
      return;
    }

    router.push(
      AppRoutes.conversationOf(targetConversationId),
      extra: {
        if (conversationVersion != null)
          'conversationVersion': conversationVersion,
        if (lastMessageId != null) 'lastMessageId': lastMessageId,
      },
    );
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
