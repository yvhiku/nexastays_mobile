import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/session/session_manager.dart';
import '../features/notifications/data/datasources/push_token_datasource.dart';
import 'notification_service.dart';

/// Registers FCM tokens with identity after auth and on token refresh.
class PushRegistrationService {
  PushRegistrationService({
    required NotificationService notificationService,
    required PushTokenDataSource pushTokenDataSource,
    required SessionManager sessionManager,
  })  : _notifications = notificationService,
        _pushTokens = pushTokenDataSource,
        _session = sessionManager;

  final NotificationService _notifications;
  final PushTokenDataSource _pushTokens;
  final SessionManager _session;

  StreamSubscription<String>? _tokenRefreshSub;
  String? _lastRegisteredToken;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _notifications.initialize();
    _tokenRefreshSub = _notifications.onTokenRefresh.listen((token) {
      unawaited(registerIfAuthenticated(token));
    });
  }

  Future<void> registerIfAuthenticated([String? tokenOverride]) async {
    if (!_session.isAuthenticated) return;
    final token = tokenOverride ?? await _notifications.getDeviceToken();
    if (token == null || token.isEmpty) return;
    if (token == _lastRegisteredToken) return;
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _pushTokens.registerPushToken(token: token, platform: platform);
      _lastRegisteredToken = token;
      if (kDebugMode) {
        print('[PushRegistration] push_registered');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PushRegistration] Failed to register token: $e');
      }
    }
  }

  Future<void> deactivateOnLogout() async {
    try {
      await _pushTokens.deactivatePushToken(token: _lastRegisteredToken);
    } catch (_) {
      /* best effort */
    }
    _lastRegisteredToken = null;
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
  }
}
