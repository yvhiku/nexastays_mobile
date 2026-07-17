import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../identity_verification/domain/entities/verification.dart';
import '../../domain/entities/host_dashboard_stats.dart';
import '../../domain/entities/host_me_status.dart';
import '../../domain/entities/host_property_manage_data.dart';
import '../../domain/repositories/host_repository.dart';
import '../../../../core/utils/listing_media_url.dart';
import '../../domain/entities/host_listing_edit_data.dart';
import '../../domain/services/listing_analytics.dart';
import '../../../property/data/datasources/property_remote_datasource.dart';
import '../../../home/data/mappers/property_to_home_mapper.dart';
import '../../../home/domain/entities/property.dart';

class HostDashboardRepositoryImpl implements HostRepository {
  HostDashboardRepositoryImpl({
    required DioClient dioClient,
    required PropertyRemoteDataSource propertyRemote,
    required BookingRepository bookingRepository,
    required BookingRemoteDataSource bookingRemote,
  })  : _client = dioClient,
        _propertyRemote = propertyRemote,
        _bookingRepository = bookingRepository,
        _bookingRemote = bookingRemote;

  final DioClient _client;
  final PropertyRemoteDataSource _propertyRemote;
  final BookingRepository _bookingRepository;
  final BookingRemoteDataSource _bookingRemote;

  @override
  Future<Either<Failure, HostMeStatus>> getHostMe() async {
    try {
      return Right(await _fetchHostMe());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HostDashboardStats>> getHostStats(String userId) async {
    try {
      final hostMe = await _fetchHostMe();
      final apiStats = await _fetchHostStatsApi();

      List<Property> listings = [];
      try {
        final listingModels = await _propertyRemote.getHostListings();
        listings = listingModels.map(propertyToHome).toList();
      } catch (_) {
        // Listings API may fail until host is approved — still show onboarding status.
      }

      final bookingsResult = await _bookingRepository.getHostBookings(userId);
      return await bookingsResult.fold(
        (f) async => Left(f),
        (bookings) async {
          final pendingBookings =
              apiStats?.pendingBookings ??
              bookings.where((b) => b.status == BookingStatus.pending).length;
          final activeBookings = apiStats?.activeBookings ??
              bookings
                  .where(
                    (b) =>
                        b.status == BookingStatus.confirmed ||
                        b.status == BookingStatus.active,
                  )
                  .length;
          final earningsTrendPct = _earningsTrendPct(bookings);

          return Right(
            HostDashboardStats(
              listings: listings,
              totalEarnings: apiStats?.totalEarnings ?? 0,
              thisMonthEarnings: apiStats?.thisMonthEarnings ?? 0,
              totalBookings: apiStats?.totalBookings ?? bookings.length,
              pendingBookings: pendingBookings,
              activeBookings: activeBookings,
              hostVerificationStatus: _mapToVerificationStatus(hostMe),
              hostMe: hostMe,
              earningsTrendPct: earningsTrendPct,
            ),
          );
        },
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<_HostStatsApi?> _fetchHostStatsApi() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.staysHostStats,
      );
      final data = response.data ?? const <String, dynamic>{};
      final payload =
          data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
      return _HostStatsApi.fromJson(payload);
    } catch (_) {
      return null;
    }
  }

  Future<HostMeStatus> _fetchHostMe() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiEndpoints.staysHostMe,
    );
    final data = response.data ?? const <String, dynamic>{};
    final payload =
        data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
    return HostMeStatus.fromJson(payload);
  }

  VerificationStatus _mapToVerificationStatus(HostMeStatus hostMe) {
    if (hostMe.isApproved) return VerificationStatus.approved;
    if (hostMe.isRejected) return VerificationStatus.rejected;
    if (hostMe.isPending) return VerificationStatus.pending;
    return VerificationStatus.notStarted;
  }

  double _earningsTrendPct(List<Booking> bookings) {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month);
    final lastMonthStart = DateTime(now.year, now.month - 1);
    var thisMonth = 0.0;
    var lastMonth = 0.0;

    for (final booking in bookings) {
      if (!booking.isConfirmed && booking.status != BookingStatus.completed) {
        continue;
      }
      final payout = booking.feeBreakdown.hostPayout;
      final ref = booking.confirmedAt ?? booking.checkIn;
      if (!ref.isBefore(thisMonthStart)) {
        thisMonth += payout;
      } else if (!ref.isBefore(lastMonthStart) && ref.isBefore(thisMonthStart)) {
        lastMonth += payout;
      }
    }

    if (lastMonth <= 0) return thisMonth > 0 ? 100 : 0;
    return ((thisMonth - lastMonth) / lastMonth) * 100;
  }

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) return m;
    }
    return e.message ?? 'Could not load host status';
  }

  @override
  Future<Either<Failure, HostPropertyManageData>> getPropertyManageData({
    required String userId,
    required String propertyId,
  }) async {
    try {
      final listingModels = await _propertyRemote.getHostListings();
      final listings = listingModels.map(propertyToHome).toList();
      final property = listings.where((p) => p.id == propertyId).firstOrNull;
      if (property == null) {
        return const Left(ServerFailure('Property not found'));
      }

      final bookingModels = await _bookingRemote.getHostBookings(userId);
      final bookings = bookingModels.cast<Booking>();
      final listingBookings =
          bookings.where((b) => b.propertyId == propertyId).toList();

      return Right(
        HostPropertyManageData(
          property: property,
          analytics: ListingAnalyticsCalculator.fromBookings(listingBookings),
          pastBookings:
              ListingAnalyticsCalculator.historyFromBookings(listingBookings),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HostListingEditData>> getListingForEdit(
    String listingId,
  ) async {
    try {
      final payload = await _fetchHostListingPayload(listingId);
      return Right(_mapHostListingEdit(payload));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final fallback = await _fetchHostListingFromList(listingId);
        if (fallback != null) {
          return Right(_mapHostListingEdit(fallback));
        }
      }
      return Left(ServerFailure(_dioMessage(e)));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HostListingEditData>> updateListing({
    required String listingId,
    String? title,
    String? city,
    String? neighborhood,
    String? address,
    String? description,
    String? checkInTime,
    String? checkOutTime,
    double? basePrice,
    double? weekendPrice,
    double? cleaningFee,
    int? maxGuests,
    String? petsPolicy,
    String? smokingPolicy,
    List<String>? amenities,
    String? accessInstructions,
    double? geoLat,
    double? geoLng,
  }) async {
    try {
      final body = <String, dynamic>{
        if (title != null) 'title': title,
        if (city != null) 'city': city,
        if (neighborhood != null) 'neighborhood': neighborhood,
        if (address != null) 'address': address,
        if (description != null) 'description': description,
        if (checkInTime != null) 'checkin_time': checkInTime,
        if (checkOutTime != null) 'checkout_time': checkOutTime,
        if (geoLat != null) 'geo_lat': geoLat,
        if (geoLng != null) 'geo_lng': geoLng,
        if (basePrice != null ||
            weekendPrice != null ||
            cleaningFee != null)
          'rate_plan': {
            if (basePrice != null) 'base_price': basePrice,
            if (weekendPrice != null) 'weekend_price': weekendPrice,
            if (cleaningFee != null) 'cleaning_fee': cleaningFee,
          },
        if (maxGuests != null ||
            petsPolicy != null ||
            smokingPolicy != null ||
            amenities != null)
          'rules': {
            if (maxGuests != null) 'max_guests': maxGuests,
            if (petsPolicy != null) 'pets_policy': petsPolicy,
            if (smokingPolicy != null) 'smoking_policy': smokingPolicy,
            if (amenities != null) 'amenities': amenities,
          },
        if (accessInstructions != null)
          'check_in_contact': {
            'access_instructions': accessInstructions,
          },
      };

      final response = await _client.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.staysHostListingById(listingId),
        data: body,
      );
      final payload = _unwrapPayload(response.data);
      return Right(_mapHostListingEdit(payload));
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> pauseListing(String listingId) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.staysHostListingPause(listingId),
      );
      final payload = _unwrapPayload(response.data);
      return Right(
        (payload['message'] ?? 'Listing paused.').toString(),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resumeListing(String listingId) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.staysHostListingResume(listingId),
      );
      final payload = _unwrapPayload(response.data);
      return Right(
        (payload['message'] ?? 'Listing resumed.').toString(),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_dioMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Map<String, dynamic>> _fetchHostListingPayload(String listingId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiEndpoints.staysHostListingById(listingId),
    );
    return _unwrapPayload(response.data);
  }

  Future<Map<String, dynamic>?> _fetchHostListingFromList(String listingId) async {
    final response = await _client.dio.get<dynamic>(
      ApiEndpoints.staysHostListings,
    );
    final list = _unwrapPayloadList(response.data);
    for (final item in list) {
      if ((item['id'] ?? '').toString() == listingId) {
        return item;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _unwrapPayloadList(dynamic data) {
    dynamic list = data;
    if (data is Map) {
      final map = data.map((key, value) => MapEntry(key.toString(), value));
      if (map['data'] is List) {
        list = map['data'];
      }
    }
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList();
  }

  Map<String, dynamic> _unwrapPayload(Map<String, dynamic>? data) {
    final root = data ?? const <String, dynamic>{};
    if (root['data'] is Map<String, dynamic>) {
      return root['data'] as Map<String, dynamic>;
    }
    if (root['data'] is Map) {
      return root['data'].map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return root;
  }

  HostListingEditData _mapHostListingEdit(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final rate = json['rate_plan'] is Map
        ? (json['rate_plan'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : const <String, dynamic>{};
    final rules = json['rules'] is Map
        ? (json['rules'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : const <String, dynamic>{};
    final contact = json['check_in_contact'] is Map
        ? (json['check_in_contact'] as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : const <String, dynamic>{};

    final media = json['media'];
    final photoUrls = <String>[];
    if (media is List) {
      for (final item in media) {
        if (item is! Map) continue;
        final kind = (item['kind'] ?? '').toString().toUpperCase();
        if (kind != 'PHOTO') continue;
        final assetId = (item['asset_id'] ?? '').toString();
        if (assetId.isEmpty) continue;
        photoUrls.add(listingMediaUrl(id, assetId));
      }
    }

    double numVal(Object? v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

    return HostListingEditData(
      id: id,
      title: (json['title'] ?? '').toString(),
      listingType: (json['listing_type'] ?? 'APARTMENT').toString(),
      city: (json['city'] ?? '').toString(),
      neighborhood: (json['neighborhood'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'DRAFT').toString(),
      checkInTime: (json['checkin_time'] ?? '14:00').toString(),
      checkOutTime: (json['checkout_time'] ?? '11:00').toString(),
      instantBooking: json['instant_booking'] == true,
      basePrice: numVal(rate['base_price']),
      weekendPrice: numVal(rate['weekend_price']),
      cleaningFee: numVal(rate['cleaning_fee']),
      currency: (rate['currency'] ?? 'MAD').toString(),
      maxGuests: (rules['max_guests'] as num?)?.toInt() ?? 1,
      petsPolicy: (rules['pets_policy'] ?? 'NO').toString(),
      smokingPolicy: (rules['smoking_policy'] ?? 'NOT_ALLOWED').toString(),
      amenities: (rules['amenities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      cancellationPolicy:
          (rules['cancellation_policy'] ?? 'MODERATE').toString(),
      contactName: (contact['full_name'] ?? '').toString(),
      contactPhone: (contact['phone'] ?? '').toString(),
      contactRole: (contact['role'] ?? 'OWNER').toString(),
      accessInstructions: (contact['access_instructions'] ?? '').toString(),
      photoUrls: photoUrls,
      geoLat: json['geo_lat'] is num
          ? (json['geo_lat'] as num).toDouble()
          : double.tryParse(json['geo_lat']?.toString() ?? ''),
      geoLng: json['geo_lng'] is num
          ? (json['geo_lng'] as num).toDouble()
          : double.tryParse(json['geo_lng']?.toString() ?? ''),
    );
  }
}

class _HostStatsApi {
  const _HostStatsApi({
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.totalBookings,
    required this.pendingBookings,
    required this.activeBookings,
  });

  final double totalEarnings;
  final double thisMonthEarnings;
  final int totalBookings;
  final int pendingBookings;
  final int activeBookings;

  factory _HostStatsApi.fromJson(Map<String, dynamic> json) {
    double numVal(Object? v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
    int intVal(Object? v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return _HostStatsApi(
      totalEarnings: numVal(json['total_earnings']),
      thisMonthEarnings: numVal(json['this_month_earnings']),
      totalBookings: intVal(json['total_bookings']),
      pendingBookings: intVal(json['pending_bookings']),
      activeBookings: intVal(json['active_bookings']),
    );
  }
}
