// =============================================================================
// NexaStays Local Storage
// =============================================================================
// Lightweight wrapper around SharedPreferences for non-sensitive data such as
// onboarding state, theme preference, cached filters, and search history.
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive key-value storage backed by [SharedPreferences].
///
/// Uses lazy initialisation — the underlying [SharedPreferences] instance is
/// created on first access and reused for all subsequent calls.
///
/// ```dart
/// final storage = LocalStorage();
/// await storage.setBool('onboarding_completed', true);
/// ```
class LocalStorage {
  LocalStorage._();

  /// Shared singleton instance.
  static final LocalStorage instance = LocalStorage._();

  /// Factory that returns the singleton.
  factory LocalStorage() => instance;

  SharedPreferences? _prefs;

  /// Returns the cached [SharedPreferences] instance, creating it lazily.
  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Bool ────────────────────────────────────────────────────────────
  // Useful for: onboarding completed, dark-mode toggle, feature flags.

  Future<void> setBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  // ── String ──────────────────────────────────────────────────────────
  // Useful for: theme name, locale code, last selected filter.

  Future<void> setString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  // ── String list ─────────────────────────────────────────────────────
  // Useful for: search history, recently viewed property IDs.

  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await _instance;
    await prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    final prefs = await _instance;
    return prefs.getStringList(key);
  }

  // ── Remove / clear ─────────────────────────────────────────────────

  /// Removes a single entry by [key].
  Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  /// Removes **all** entries. Use with caution.
  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
