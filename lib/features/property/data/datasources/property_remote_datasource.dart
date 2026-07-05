import '../../../../app/env/env_bootstrap.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/property_model.dart';
import '../models/review_model.dart';
import '../../../host_dashboard/data/models/host_reviews_payload.dart';
import '../../domain/entities/listing_reviews_result.dart';

abstract class PropertyRemoteDataSource {
  Future<List<PropertyModel>> getProperties({
    String? city,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    bool? verifiedOnly,
    bool? instantBookOnly,
    bool? featured,
    bool? trending,
    String? guestType,
    List<String>? vibeTags,
    double? minPrice,
    double? maxPrice,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  });

  Future<PropertyModel> getPropertyById(String id);

  Future<ListingReviewsResult> getReviews({
    required String propertyId,
    int page = 1,
    int limit = 10,
  });

  Future<List<PropertyModel>> getFeaturedProperties();
  Future<List<PropertyModel>> getTrendingProperties();

  /// Authenticated host's own listings (`GET /stays/host/listings`).
  Future<List<PropertyModel>> getHostListings();

  Future<HostReviewsPayload> getHostReviews({int page = 1, int limit = 20});

  Future<void> saveProperty(String userId, String propertyId);
  Future<void> unsaveProperty(String userId, String propertyId);
  Future<List<PropertyModel>> getSavedProperties(String userId);
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  PropertyRemoteDataSourceImpl({required this.client});
  final DioClient client;

  dynamic _unwrap(dynamic body) {
    if (body is Map) {
      final map = _asStringMap(body);
      final inner = map['data'];
      if (inner != null) return inner;
      return map;
    }
    return body;
  }

  void _assertSuccess(int? code, dynamic body) {
    if (code == null || code >= 300) {
      throw ServerException(
        (body is Map<String, dynamic> ? body['message'] : null)?.toString() ??
            'Unexpected server error ($code)',
      );
    }
  }

  String _mediaUrl(String listingId, String assetId) =>
      '${currentEnv.staysBaseUrl}${ApiEndpoints.listingMedia(listingId, assetId)}';

  Map<String, dynamic> _asStringMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) {
      return body.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const ServerException('Unexpected listing response');
  }

  String _cleanAddress(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return '';
    return text;
  }

  String _formatAddressForDisplay(String address) {
    return address
        .replaceAll(RegExp(r'\.\s+'), ', ')
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map((part) {
          if (part.length <= 3) return part.toUpperCase();
          return part
              .split(RegExp(r'\s+'))
              .map((word) {
                if (word.isEmpty) return word;
                if (RegExp(r'^\d+$').hasMatch(word)) return word;
                return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
              })
              .join(' ');
        })
        .join(', ');
  }

  String _resolveAddress(Map<String, dynamic> json) {
    for (final key in ['address', 'address_encrypted', 'exact_address']) {
      final cleaned = _cleanAddress(json[key]);
      if (cleaned.isNotEmpty) return cleaned;
    }
    return '';
  }

  String _parseNeighborhood(Map<String, dynamic> json, String address, String city) {
    final fromApi = (json['neighborhood'] ?? '').toString().trim();
    if (fromApi.isNotEmpty && !_isFloorFragment(fromApi)) return fromApi;
    if (address.isEmpty) return '';

    final parts = address
        .replaceAll(RegExp(r'\.\s+'), ', ')
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      final cityLower = city.toLowerCase();
      for (var i = parts.length - 1; i >= 0; i--) {
        if (parts[i].toLowerCase() == cityLower && i > 0) {
          final candidate = parts[i - 1];
          return _isFloorFragment(candidate) ? '' : candidate;
        }
      }
      final candidate = parts[parts.length - 2];
      return _isFloorFragment(candidate) ? '' : candidate;
    }
    return '';
  }

  bool _isFloorFragment(String text) {
    return RegExp(
      r'^(étage|etage|floor|level|apt|apartment|appartement|studio)\b',
      caseSensitive: false,
    ).hasMatch(text.trim());
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic>? _nestedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return _asStringMap(value);
    return null;
  }

  List<Map<String, dynamic>> _nestedMapList(dynamic value) {
    if (value is! List) return const [];
    final out = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        out.add(item);
      } else if (item is Map) {
        out.add(_asStringMap(item));
      }
    }
    return out;
  }

  PropertyModel _mapListing(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final city = (json['city'] ?? '').toString();
    final address = _resolveAddress(json);
    final displayAddress =
        address.isNotEmpty ? _formatAddressForDisplay(address) : '';
    final neighborhood = _parseNeighborhood(json, address, city);
    final description = (json['description'] ?? '').toString();
    final listingType = (json['listing_type'] ?? 'APARTMENT').toString();
    final ratePlan = _nestedMap(json['rate_plan']) ?? const {};
    final rules = _nestedMap(json['rules']) ?? const {};
    final host = _nestedMap(json['host']) ?? const {};
    final media = _nestedMapList(json['media']);

    final photoUrls = media
        .where((m) => (m['kind'] ?? '').toString().toUpperCase() == 'PHOTO')
        .map((m) => _mediaUrl(id, (m['asset_id'] ?? '').toString()))
        .where((u) => u.isNotEmpty)
        .toList();
    final walkthrough = media
        .where((m) => (m['kind'] ?? '').toString().toUpperCase() == 'WALKTHROUGH')
        .map((m) => _mediaUrl(id, (m['asset_id'] ?? '').toString()))
        .toList();

    return PropertyModel(
      id: id,
      hostId: (host['id'] ?? '').toString(),
      name: title,
      description: description,
      city: city,
      neighborhood: neighborhood,
      exactAddress: displayAddress.isNotEmpty ? displayAddress : address,
      propertyType: listingType,
      hostType: 'professional',
      beds: 1,
      bathrooms: 1,
      maxGuests: (rules['max_guests'] as num?)?.toInt() ?? 1,
      nightlyRate: (ratePlan['base_price'] as num?)?.toDouble() ?? 0,
      minimumNights: 1,
      photoUrls: photoUrls,
      walkthroughVideoUrl: walkthrough.isNotEmpty ? walkthrough.first : null,
      amenities: (rules['amenities'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      rules: HostPreferencesModel(
        checkInFrom: (json['checkin_time'] ?? '14:00').toString(),
        checkOutBefore: (json['checkout_time'] ?? '11:00').toString(),
        maxGuests: (rules['max_guests'] as num?)?.toInt() ?? 1,
      ),
      rating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isVerified: walkthrough.isNotEmpty,
      isInstantBook: json['instant_booking'] == true,
      vibeTags: const [],
      checkInContact: (host['full_name'] ?? '').toString(),
      checkInInstructions: '',
      checkInMethod: '',
      isTrending: false,
      listedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      listingStatus: (json['status'] ?? 'LIVE').toString(),
      latitude: _parseCoordinate(json['geo_lat']),
      longitude: _parseCoordinate(json['geo_lng']),
    );
  }

  @override
  Future<List<PropertyModel>> getProperties({
    String? city,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    bool? verifiedOnly,
    bool? instantBookOnly,
    bool? featured,
    bool? trending,
    String? guestType,
    List<String>? vibeTags,
    double? minPrice,
    double? maxPrice,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      if (city != null && city.isNotEmpty) 'city': city,
      if (checkIn != null)
        'checkin_date': checkIn.toIso8601String().split('T').first,
      if (checkOut != null)
        'checkout_date': checkOut.toIso8601String().split('T').first,
      if (guests != null && guests > 0) 'guests': guests,
      if (verifiedOnly == true) 'verified_walkthrough_only': true,
      if (instantBookOnly == true) 'instant_booking_only': true,
    };
    final response =
        await client.get(ApiEndpoints.staysListingsSearch, queryParameters: query);
    _assertSuccess(response.statusCode, response.data);
    final list = _unwrap(response.data);
    if (list is! List) return const [];
    final results = <PropertyModel>[];
    for (final item in list) {
      if (item is! Map) continue;
      try {
        results.add(_mapListing(_asStringMap(item)));
      } catch (_) {
        // Skip malformed listings instead of failing the whole search.
      }
    }
    return results;
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    final response = await client.get(
      ApiEndpoints.listingById(id),
      queryParameters: {'_ts': DateTime.now().millisecondsSinceEpoch},
    );
    _assertSuccess(response.statusCode, response.data);
    final body = _unwrap(response.data);
    return _mapListing(_asStringMap(body));
  }

  @override
  Future<ListingReviewsResult> getReviews({
    required String propertyId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await client.get(
      ApiEndpoints.listingReviews(propertyId),
      queryParameters: {'page': page, 'limit': limit},
    );
    _assertSuccess(response.statusCode, response.data);
    final unboxed = _unwrap(response.data);
    final map = unboxed is Map<String, dynamic> ? unboxed : null;
    final raw = map != null ? map['reviews'] : null;
    final list = raw is List ? raw : const [];
    final reviewModels = list
        .whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .toList();

    var apiTotal =
        map != null ? (map['total'] as num?)?.toInt() : reviewModels.length;
    Map<int, double> distribution = {};
    double? summaryAvg;

    final sumRaw = map != null ? map['summary'] : null;
    if (sumRaw is Map<String, dynamic>) {
      apiTotal =
          (sumRaw['total_count'] as num?)?.toInt() ??
          apiTotal ??
          reviewModels.length;
      summaryAvg =
          (sumRaw['overall_avg_rating'] as num?)?.toDouble();

      final dist = sumRaw['distribution_pct'];
      if (dist is Map) {
        for (final e in dist.entries) {
          final star = int.tryParse(e.key.toString());
          final pct = (e.value as num?)?.toDouble();
          if (star != null &&
              pct != null &&
              star >= 1 &&
              star <= 5) {
            distribution[star] = pct;
          }
        }
      }
    }

    apiTotal ??= reviewModels.length;

    return ListingReviewsResult(
      reviews: reviewModels,
      apiTotalCount: apiTotal,
      distributionPct: distribution,
      summaryAvgRating: summaryAvg,
    );
  }

  @override
  Future<List<PropertyModel>> getFeaturedProperties() => getProperties(featured: true);

  @override
  Future<List<PropertyModel>> getTrendingProperties() => getProperties(trending: true);

  @override
  Future<HostReviewsPayload> getHostReviews({int page = 1, int limit = 20}) async {
    final response = await client.get(
      ApiEndpoints.staysHostReviews,
      queryParameters: {'page': page, 'limit': limit},
    );
    _assertSuccess(response.statusCode, response.data);
    final unboxed = _unwrap(response.data);
    final map = unboxed is Map<String, dynamic> ? unboxed : null;
    if (map == null) {
      throw const ServerException('Unexpected host reviews response');
    }
    return HostReviewsPayload.fromJson(map);
  }

  @override
  Future<List<PropertyModel>> getHostListings() async {
    final response = await client.get(ApiEndpoints.staysHostListings);
    _assertSuccess(response.statusCode, response.data);
    final list = _unwrap(response.data);
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((item) => _mapListing(_asStringMap(item)))
        .toList();
  }

  @override
  Future<void> saveProperty(String userId, String propertyId) async {}

  @override
  Future<void> unsaveProperty(String userId, String propertyId) async {}

  @override
  Future<List<PropertyModel>> getSavedProperties(String userId) async => const [];
}
