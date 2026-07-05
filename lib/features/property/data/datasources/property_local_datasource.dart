import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/property_model.dart';
import '../models/review_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Abstract contract
// ─────────────────────────────────────────────────────────────────────────────

abstract class PropertyLocalDataSource {
  Future<void> cacheFeaturedProperties(List<PropertyModel> properties);
  Future<List<PropertyModel>> getCachedFeaturedProperties();

  Future<void> cacheTrendingProperties(List<PropertyModel> properties);
  Future<List<PropertyModel>> getCachedTrendingProperties();

  Future<void> cachePropertyDetail(PropertyModel property);
  Future<PropertyModel> getCachedPropertyDetail(String id);

  Future<void> cacheReviews(String propertyId, List<ReviewModel> reviews);
  Future<List<ReviewModel>> getCachedReviews(String propertyId);

  Future<void> cacheSavedProperties(String userId, List<PropertyModel> properties);
  Future<List<PropertyModel>> getCachedSavedProperties(String userId);

  Future<void> clearPropertyCache();
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  final LocalStorage localStorage;

  PropertyLocalDataSourceImpl({required this.localStorage});

  // ── Cache keys ─────────────────────────────────────────────────────────

  static const _featuredKey  = 'cached_featured_properties';
  static const _trendingKey  = 'cached_trending_properties';
  static const _detailPrefix = 'cached_property_';
  static const _savedKey     = 'cached_saved_properties_';
  static const _reviewPrefix = 'cached_reviews_';

  // ── Featured ───────────────────────────────────────────────────────────

  @override
  Future<void> cacheFeaturedProperties(List<PropertyModel> properties) async {
    final jsonList = properties.map((p) => p.toJson()).toList();
    await localStorage.setString(_featuredKey, jsonEncode(jsonList));
  }

  @override
  Future<List<PropertyModel>> getCachedFeaturedProperties() async {
    return _getCachedPropertyList(_featuredKey);
  }

  // ── Trending ───────────────────────────────────────────────────────────

  @override
  Future<void> cacheTrendingProperties(List<PropertyModel> properties) async {
    final jsonList = properties.map((p) => p.toJson()).toList();
    await localStorage.setString(_trendingKey, jsonEncode(jsonList));
  }

  @override
  Future<List<PropertyModel>> getCachedTrendingProperties() async {
    return _getCachedPropertyList(_trendingKey);
  }

  // ── Property Detail ────────────────────────────────────────────────────

  @override
  Future<void> cachePropertyDetail(PropertyModel property) async {
    await localStorage.setString(
      '$_detailPrefix${property.id}',
      jsonEncode(property.toJson()),
    );
  }

  @override
  Future<PropertyModel> getCachedPropertyDetail(String id) async {
    final jsonString = await localStorage.getString('$_detailPrefix$id');
    if (jsonString == null) {
      throw const CacheException('No cached property detail found');
    }
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PropertyModel.fromJson(json);
    } catch (_) {
      throw const CacheException('Failed to parse cached property detail');
    }
  }

  // ── Reviews ────────────────────────────────────────────────────────────

  @override
  Future<void> cacheReviews(String propertyId, List<ReviewModel> reviews) async {
    final jsonList = reviews.map((r) => r.toJson()).toList();
    await localStorage.setString('$_reviewPrefix$propertyId', jsonEncode(jsonList));
  }

  @override
  Future<List<ReviewModel>> getCachedReviews(String propertyId) async {
    final jsonString = await localStorage.getString('$_reviewPrefix$propertyId');
    if (jsonString == null) {
      throw const CacheException('No cached reviews found');
    }
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to parse cached reviews');
    }
  }

  // ── Saved Properties ───────────────────────────────────────────────────

  @override
  Future<void> cacheSavedProperties(
    String userId,
    List<PropertyModel> properties,
  ) async {
    final jsonList = properties.map((p) => p.toJson()).toList();
    await localStorage.setString('$_savedKey$userId', jsonEncode(jsonList));
  }

  @override
  Future<List<PropertyModel>> getCachedSavedProperties(String userId) async {
    return _getCachedPropertyList('$_savedKey$userId');
  }

  // ── Clear ──────────────────────────────────────────────────────────────

  @override
  Future<void> clearPropertyCache() async {
    await localStorage.remove(_featuredKey);
    await localStorage.remove(_trendingKey);
    // Detail, review, and saved keys are prefixed — remove them individually
    // if the localStorage exposes keys. For now, we clear the known static keys.
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Future<List<PropertyModel>> _getCachedPropertyList(String key) async {
    final jsonString = await localStorage.getString(key);
    if (jsonString == null) {
      throw const CacheException('No cached data found');
    }
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Failed to parse cached data');
    }
  }
}
