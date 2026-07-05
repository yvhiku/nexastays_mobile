import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../property/data/models/property_model.dart';

// =============================================================================
// Wishlist Local Data Source
// =============================================================================

/// Contract for local wishlist persistence.
///
/// All data is stored on-device via [LocalStorage] (SharedPreferences).
/// No network calls are involved.
abstract class WishlistLocalDataSource {
  /// Returns the set of saved property IDs for the given [userId].
  Future<Set<String>> getSavedIds(String userId);

  /// Adds [propertyId] to the saved set for [userId].
  Future<void> saveId(String userId, String propertyId);

  /// Removes [propertyId] from the saved set for [userId].
  Future<void> removeId(String userId, String propertyId);

  /// Returns `true` if [propertyId] is in the saved set for [userId].
  Future<bool> isSaved(String userId, String propertyId);

  /// Caches a full [PropertyModel] for [userId]; updates in-place if the
  /// same id already exists.
  Future<void> cacheProperty(String userId, PropertyModel property);

  /// Returns all cached [PropertyModel]s whose IDs still appear in the
  /// saved-IDs set (consistency check). Throws [CacheException] if not found.
  Future<List<PropertyModel>> getCachedProperties(String userId);

  /// Removes a single cached property by [propertyId] for [userId].
  Future<void> removeCachedProperty(String userId, String propertyId);

  /// Deletes both the saved-IDs list and the cached-properties list
  /// for [userId].
  Future<void> clearWishlist(String userId);
}

// =============================================================================
// Implementation
// =============================================================================

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  WishlistLocalDataSourceImpl(this._storage);

  final LocalStorage _storage;

  static const _savedIdsPrefix = 'wishlist_ids_';
  static const _savedPropsPrefix = 'wishlist_props_';

  // ── Helpers ──────────────────────────────────────────────────────────

  String _idsKey(String userId) => '$_savedIdsPrefix$userId';
  String _propsKey(String userId) => '$_savedPropsPrefix$userId';

  Future<Set<String>> _readIds(String userId) async {
    final raw = await _storage.getString(_idsKey(userId));
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => e as String).toSet();
  }

  Future<void> _writeIds(String userId, Set<String> ids) async {
    await _storage.setString(_idsKey(userId), jsonEncode(ids.toList()));
  }

  Future<List<PropertyModel>> _readProps(String userId) async {
    final raw = await _storage.getString(_propsKey(userId));
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeProps(
    String userId,
    List<PropertyModel> props,
  ) async {
    final jsonList = props.map((p) => p.toJson()).toList();
    await _storage.setString(_propsKey(userId), jsonEncode(jsonList));
  }

  // ── Public API ───────────────────────────────────────────────────────

  @override
  Future<Set<String>> getSavedIds(String userId) => _readIds(userId);

  @override
  Future<void> saveId(String userId, String propertyId) async {
    final ids = await _readIds(userId);
    ids.add(propertyId);
    await _writeIds(userId, ids);
  }

  @override
  Future<void> removeId(String userId, String propertyId) async {
    final ids = await _readIds(userId);
    ids.remove(propertyId);
    await _writeIds(userId, ids);

    // Also remove from cached property list for consistency.
    await removeCachedProperty(userId, propertyId);
  }

  @override
  Future<bool> isSaved(String userId, String propertyId) async {
    final ids = await _readIds(userId);
    return ids.contains(propertyId);
  }

  @override
  Future<void> cacheProperty(String userId, PropertyModel property) async {
    final props = await _readProps(userId);
    final index = props.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      props[index] = property; // update in place
    } else {
      props.add(property);
    }
    await _writeProps(userId, props);
  }

  @override
  Future<List<PropertyModel>> getCachedProperties(String userId) async {
    final props = await _readProps(userId);

    // Consistency check — keep only IDs still in the saved set.
    final ids = await _readIds(userId);
    return props.where((p) => ids.contains(p.id)).toList();
  }

  @override
  Future<void> removeCachedProperty(
    String userId,
    String propertyId,
  ) async {
    final props = await _readProps(userId);
    props.removeWhere((p) => p.id == propertyId);
    await _writeProps(userId, props);
  }

  @override
  Future<void> clearWishlist(String userId) async {
    await _storage.remove(_idsKey(userId));
    await _storage.remove(_propsKey(userId));
  }
}
