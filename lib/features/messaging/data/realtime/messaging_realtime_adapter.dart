import 'dart:async';

import 'package:flutter/widgets.dart';

/// Adaptive idle-aware polling for messaging sync.
/// Conversation open: 5s active, 10s idle 30s–5min, 20s after 5min.
/// Inbox only: 30s. Background: off.
enum MessagingRealtimeMode { conversation, inbox, off }

typedef MessagingRealtimePollHandler = FutureOr<void> Function();

class MessagingRealtimeAdapter with WidgetsBindingObserver {
  MessagingRealtimeAdapter();

  static const _activeMs = 5000;
  static const _idleMs = 10000;
  static const _veryIdleMs = 20000;
  static const _inboxMs = 30000;
  static const _activeThresholdMs = 30000;
  static const _idleThresholdMs = 5 * 60000;

  MessagingRealtimeMode _mode = MessagingRealtimeMode.off;
  MessagingRealtimePollHandler? _handler;
  Timer? _timer;
  DateTime _lastActivityAt = DateTime.now();
  bool _visible = true;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
    stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _visible = state == AppLifecycleState.resumed;
    if (!_visible) {
      _stopTimer();
    } else if (_mode != MessagingRealtimeMode.off && _handler != null) {
      unawaited(_tick());
      _scheduleNext();
    }
  }

  void bumpActivity() {
    _lastActivityAt = DateTime.now();
  }

  void start(
    MessagingRealtimeMode mode,
    MessagingRealtimePollHandler handler,
  ) {
    _mode = mode;
    _handler = handler;
    bumpActivity();
    _stopTimer();
    if (mode != MessagingRealtimeMode.off && _visible) {
      unawaited(_tick());
      _scheduleNext();
    }
  }

  void stop() {
    _mode = MessagingRealtimeMode.off;
    _handler = null;
    _stopTimer();
  }

  int _intervalMs() {
    if (_mode == MessagingRealtimeMode.off || !_visible) return 0;
    if (_mode == MessagingRealtimeMode.inbox) return _inboxMs;

    final idle = DateTime.now().difference(_lastActivityAt).inMilliseconds;
    if (idle < _activeThresholdMs) return _activeMs;
    if (idle < _idleThresholdMs) return _idleMs;
    return _veryIdleMs;
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleNext() {
    _stopTimer();
    final ms = _intervalMs();
    if (ms <= 0 || _handler == null) return;
    _timer = Timer(Duration(milliseconds: ms), () {
      unawaited(_tick());
      _scheduleNext();
    });
  }

  Future<void> _tick() async {
    if (_handler == null ||
        _mode == MessagingRealtimeMode.off ||
        !_visible) {
      return;
    }
    try {
      await _handler!.call();
    } catch (_) {
      // Polling errors are non-fatal.
    }
  }
}

MessagingRealtimeAdapter? _sharedAdapter;

MessagingRealtimeAdapter getMessagingRealtimeAdapter() {
  return _sharedAdapter ??= MessagingRealtimeAdapter()..attach();
}
