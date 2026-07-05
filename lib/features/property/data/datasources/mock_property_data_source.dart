import '../models/property_model.dart';
import '../models/review_model.dart';
import '../../../search/domain/entities/search_filter.dart';
import 'property_data_source.dart';

/// Mock implementation of [PropertyDataSource] for offline/development use.
///
/// No seeded listings or reviews — data must come from the real API.
class MockPropertyDataSource implements PropertyDataSource {
  final _savedPropertyIds = <String, Set<String>>{};

  static final List<Map<String, dynamic>> _mockPropertiesJson = [];
  static final List<Map<String, dynamic>> _mockReviewsJson = [];

  // ── Parsed models (lazy) ───────────────────────────────────────────────

  late final List<PropertyModel> _properties =
      _mockPropertiesJson.map(PropertyModel.fromJson).toList();

  late final List<ReviewModel> _reviews =
      _mockReviewsJson.map(ReviewModel.fromJson).toList();

  // ── Simulate network delay ─────────────────────────────────────────────

  Future<T> _delay<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return value;
  }

  // ── PropertyDataSource implementation ──────────────────────────────────

  @override
  Future<List<PropertyModel>> getProperties({
    SearchFilter? filter,
    bool featured = false,
    bool trending = false,
  }) async {
    var result = List<PropertyModel>.from(_properties);

    if (filter != null) {
      if (filter.city != null) {
        result = result
            .where((p) => p.city.toLowerCase() == filter.city!.toLowerCase())
            .toList();
      }
      if (filter.verifiedOnly) {
        result = result.where((p) => p.isVerified).toList();
      }
      if (filter.instantBookOnly) {
        result = result.where((p) => p.isInstantBook).toList();
      }
      if (filter.minPrice != null) {
        result =
            result.where((p) => p.nightlyRate >= filter.minPrice!).toList();
      }
      if (filter.maxPrice != null) {
        result =
            result.where((p) => p.nightlyRate <= filter.maxPrice!).toList();
      }
      if (filter.minBeds != null) {
        result = result.where((p) => p.beds >= filter.minBeds!).toList();
      }
      if (filter.guestCount > 0) {
        result = result.where((p) => p.maxGuests >= filter.guestCount).toList();
      }
      if (filter.vibes.isNotEmpty) {
        result = result
            .where((p) =>
                p.vibeTags.any((t) => filter.vibes.contains(t)))
            .toList();
      }
    }

    if (featured) {
      result =
          result.where((p) => p.isVerified && p.rating >= 4.5).toList();
    }
    if (trending) {
      result = result.where((p) => p.isTrending).toList();
    }

    return _delay(result);
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    final property = _properties.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Property not found'),
    );
    return _delay(property);
  }

  @override
  Future<List<ReviewModel>> getReviews({
    required String propertyId,
    int page = 1,
    int limit = 10,
  }) async {
    final propertyReviews =
        _reviews.where((r) => r.propertyId == propertyId).toList();
    final start = (page - 1) * limit;
    final end = start + limit;
    final paged = propertyReviews.sublist(
      start.clamp(0, propertyReviews.length),
      end.clamp(0, propertyReviews.length),
    );
    return _delay(paged);
  }

  @override
  Future<List<PropertyModel>> getFeaturedProperties() async {
    final result =
        _properties.where((p) => p.isVerified && p.rating >= 4.5).toList();
    return _delay(result);
  }

  @override
  Future<List<PropertyModel>> getTrendingProperties() async {
    final result = _properties.where((p) => p.isTrending).toList();
    return _delay(result);
  }

  @override
  Future<List<PropertyModel>> getSavedProperties(String userId) async {
    final ids = _savedPropertyIds[userId] ?? {};
    final result = _properties.where((p) => ids.contains(p.id)).toList();
    return _delay(result);
  }

  @override
  Future<void> saveProperty({
    required String userId,
    required String propertyId,
  }) async {
    _savedPropertyIds.putIfAbsent(userId, () => {});
    _savedPropertyIds[userId]!.add(propertyId);
    return _delay(null);
  }

  @override
  Future<void> unsaveProperty({
    required String userId,
    required String propertyId,
  }) async {
    _savedPropertyIds[userId]?.remove(propertyId);
    return _delay(null);
  }

  @override
  Future<bool> isPropertySaved({
    required String userId,
    required String propertyId,
  }) async {
    final saved = _savedPropertyIds[userId]?.contains(propertyId) ?? false;
    return _delay(saved);
  }
}
