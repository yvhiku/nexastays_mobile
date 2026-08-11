// =============================================================================
// NexaStays Secure Storage Service
// =============================================================================
// Singleton wrapper around flutter_secure_storage for persisting sensitive
// data (tokens, user ID) in the platform's encrypted key-value store.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Well-known secure-storage keys for Nexa Stays mobile auth.
///
/// Keep session token keys distinct from registration secrets so callers can
/// clear one without the other (SEC-011).
class SecureStorageKeys {
  SecureStorageKeys._();

  static const String accessToken = 'nexastays_access_token';
  static const String refreshToken = 'nexastays_refresh_token';
  static const String userId = 'nexastays_user_id';

  /// Identity OTP / identity_session binder for new-user registration.
  static const String otpSessionToken = 'nexastays_otp_session_token';

  /// Normalized phone retained across KYC / registration steps.
  static const String phoneNumber = 'nexastays_phone_number';

  /// Durable device id for `x-device-id` — must survive logout.
  static const String deviceId = 'nexastays_device_id';
}

/// Encrypted key-value storage for tokens and sensitive user data.
///
/// Uses the singleton pattern so the same instance (and underlying platform
/// channel) is shared across the app.
class SecureStorageService {
  SecureStorageService._({
    FlutterSecureStorage? platform,
    Map<String, String>? memory,
  })  : _platform = platform,
        _memory = memory;

  /// The single shared instance (platform secure storage).
  static final SecureStorageService instance = SecureStorageService._(
    platform: const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  /// Factory constructor that always returns the singleton.
  factory SecureStorageService() => instance;

  /// In-memory backend for unit tests (does not touch the platform channel).
  @visibleForTesting
  factory SecureStorageService.forTesting([Map<String, String>? store]) {
    return SecureStorageService._(memory: store ?? <String, String>{});
  }

  final FlutterSecureStorage? _platform;
  final Map<String, String>? _memory;

  bool get _useMemory => _memory != null;

  // ── Access token ────────────────────────────────────────────────────

  Future<void> saveAccessToken(String token) =>
      write(SecureStorageKeys.accessToken, token);

  Future<String?> getAccessToken() => read(SecureStorageKeys.accessToken);

  // ── Refresh token ───────────────────────────────────────────────────

  Future<void> saveRefreshToken(String token) =>
      write(SecureStorageKeys.refreshToken, token);

  Future<String?> getRefreshToken() => read(SecureStorageKeys.refreshToken);

  // ── User ID ─────────────────────────────────────────────────────────

  Future<void> saveUserId(String id) => write(SecureStorageKeys.userId, id);

  Future<String?> getUserId() => read(SecureStorageKeys.userId);

  // ── Bulk clear ──────────────────────────────────────────────────────

  /// Removes access / refresh / userId only.
  ///
  /// Does **not** clear registration secrets (OTP binder, phone). Call
  /// [clearRegistrationSecrets] from full logout / auth wipe paths (SEC-011).
  Future<void> clearTokens() async {
    await Future.wait([
      delete(SecureStorageKeys.accessToken),
      delete(SecureStorageKeys.refreshToken),
      delete(SecureStorageKeys.userId),
    ]);
  }

  /// Removes OTP binder + phone used for mid-registration / KYC.
  ///
  /// Does **not** clear session tokens or [SecureStorageKeys.deviceId].
  Future<void> clearRegistrationSecrets() async {
    await Future.wait([
      delete(SecureStorageKeys.otpSessionToken),
      delete(SecureStorageKeys.phoneNumber),
    ]);
  }

  /// Removes all Nexa Stays secure entries (including device id).
  Future<void> clearAll() async {
    if (_useMemory) {
      _memory!.clear();
      return;
    }
    await _platform!.deleteAll();
  }

  // ── Generic helpers ─────────────────────────────────────────────────

  Future<void> write(String key, String value) async {
    if (_useMemory) {
      _memory![key] = value;
      return;
    }
    await _platform!.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    if (_useMemory) {
      return _memory![key];
    }
    return _platform!.read(key: key);
  }

  Future<void> delete(String key) async {
    if (_useMemory) {
      _memory!.remove(key);
      return;
    }
    await _platform!.delete(key: key);
  }
}
