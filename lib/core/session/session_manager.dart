// =============================================================================
// NexaStays Session Manager
// =============================================================================
// Manages the in-memory auth state and persists tokens via SecureStorageService.
// Used by AuthInterceptor for token injection and silent refresh.
// =============================================================================

import 'dart:async';

import '../../app/env/env_bootstrap.dart';
import '../storage/secure_storage.dart';

/// Centralised authentication session state.
///
/// Keeps tokens cached in memory for fast synchronous reads (used by
/// [AuthInterceptor.onRequest]) while persisting them in encrypted storage
/// so they survive app restarts.
///
/// Thread safety: all mutations go through [_guard] so concurrent calls
/// (e.g. parallel API requests triggering refresh) are serialised.
class SessionManager {
  SessionManager({
    SecureStorageService? storage,
  }) : _storage = storage ?? SecureStorageService.instance;

  final SecureStorageService _storage;

  // ── In-memory cache ─────────────────────────────────────────────────

  String? _accessToken;
  String? _refreshToken;
  String? _userId;

  /// Current access token (may be `null` if not loaded or cleared).
  String? get accessToken => _accessToken;

  /// Current refresh token.
  String? get refreshToken => _refreshToken;

  /// Authenticated user's ID.
  String? get userId => _userId;

  /// Identity API base URL (token refresh).
  String? get baseUrl => currentEnv.identityBaseUrl;

  /// `true` when a valid access token is cached in memory.
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  // ── Serialisation guard ─────────────────────────────────────────────

  Completer<void>? _guard;

  /// Ensures only one mutation runs at a time.
  Future<void> _serialise(Future<void> Function() action) async {
    // Wait for any in-flight mutation to finish.
    while (_guard != null && !_guard!.isCompleted) {
      await _guard!.future;
    }

    _guard = Completer<void>();
    try {
      await action();
    } finally {
      _guard!.complete();
    }
  }

  // ── Load ────────────────────────────────────────────────────────────

  /// Hydrates the in-memory cache from secure storage.
  ///
  /// Call once during app startup (e.g. in `main()` or splash screen).
  Future<void> loadSession() => _serialise(() async {
        _accessToken = await _storage.getAccessToken();
        _refreshToken = await _storage.getRefreshToken();
        _userId = await _storage.getUserId();
      });

  // ── Save ────────────────────────────────────────────────────────────

  /// Persists a full set of session credentials.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) =>
      _serialise(() async {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
        _userId = userId;

        await Future.wait([
          _storage.saveAccessToken(accessToken),
          _storage.saveRefreshToken(refreshToken),
          _storage.saveUserId(userId),
        ]);
      });

  // ── Update tokens (used by AuthInterceptor after refresh) ───────────

  /// Updates only the token pair without changing the user ID.
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) =>
      _serialise(() async {
        _accessToken = accessToken;
        if (refreshToken != null) _refreshToken = refreshToken;

        await _storage.saveAccessToken(accessToken);
        if (refreshToken != null) {
          await _storage.saveRefreshToken(refreshToken);
        }
      });

  // ── Clear (logout) ─────────────────────────────────────────────────

  /// Wipes both the in-memory cache and persisted tokens.
  Future<void> clear() => _serialise(() async {
        _accessToken = null;
        _refreshToken = null;
        _userId = null;

        await _storage.clearTokens();
      });

  /// Alias for [clear] — reads more naturally in feature code.
  Future<void> clearSession() => clear();

  // ── Async accessors (convenience) ───────────────────────────────────

  /// Returns the access token, loading from storage if needed.
  Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    _accessToken = await _storage.getAccessToken();
    return _accessToken;
  }

  /// Returns the refresh token, loading from storage if needed.
  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) return _refreshToken;
    _refreshToken = await _storage.getRefreshToken();
    return _refreshToken;
  }
}
