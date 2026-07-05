// =============================================================================
// NexaStays Secure Storage Service
// =============================================================================
// Singleton wrapper around flutter_secure_storage for persisting sensitive
// data (tokens, user ID) in the platform's encrypted key-value store.
// =============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage keys — keep in sync with [SecureStorageService] methods.
class _Keys {
  _Keys._();

  static const String accessToken = 'nexastays_access_token';
  static const String refreshToken = 'nexastays_refresh_token';
  static const String userId = 'nexastays_user_id';
}

/// Encrypted key-value storage for tokens and sensitive user data.
///
/// Uses the singleton pattern so the same instance (and underlying platform
/// channel) is shared across the app.
///
/// ```dart
/// final storage = SecureStorageService.instance;
/// await storage.saveAccessToken('eyJhbGci...');
/// ```
class SecureStorageService {
  SecureStorageService._();

  /// The single shared instance.
  static final SecureStorageService instance = SecureStorageService._();

  /// Factory constructor that always returns the singleton.
  factory SecureStorageService() => instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Access token ────────────────────────────────────────────────────

  /// Persists the JWT access token.
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _Keys.accessToken, value: token);

  /// Reads the stored access token, or `null` if none exists.
  Future<String?> getAccessToken() => _storage.read(key: _Keys.accessToken);

  // ── Refresh token ───────────────────────────────────────────────────

  /// Persists the JWT refresh token.
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _Keys.refreshToken, value: token);

  /// Reads the stored refresh token, or `null` if none exists.
  Future<String?> getRefreshToken() => _storage.read(key: _Keys.refreshToken);

  // ── User ID ─────────────────────────────────────────────────────────

  /// Persists the authenticated user's ID.
  Future<void> saveUserId(String id) =>
      _storage.write(key: _Keys.userId, value: id);

  /// Reads the stored user ID, or `null` if none exists.
  Future<String?> getUserId() => _storage.read(key: _Keys.userId);

  // ── Bulk clear ──────────────────────────────────────────────────────

  /// Removes all authentication tokens and user ID from secure storage.
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _Keys.accessToken),
      _storage.delete(key: _Keys.refreshToken),
      _storage.delete(key: _Keys.userId),
    ]);
  }

  /// Removes all Nexa Stays secure entries.
  Future<void> clearAll() => _storage.deleteAll();

  // ── Generic helpers ─────────────────────────────────────────────────

  /// Writes an arbitrary key-value pair to secure storage.
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  /// Reads an arbitrary value by key, or `null` if not found.
  Future<String?> read(String key) => _storage.read(key: key);

  /// Deletes a single entry by key.
  Future<void> delete(String key) => _storage.delete(key: key);
}
