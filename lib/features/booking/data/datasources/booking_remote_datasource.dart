import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/listing_media_url.dart';
import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required String propertyId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    String? specialRequests,
    List<Map<String, dynamic>>? occupants,
  });

  Future<BookingModel> getBookingById(String bookingId);
  Future<List<BookingModel>> getGuestBookings(String guestId);
  Future<List<BookingModel>> getHostBookings(String hostId);
  Future<BookingModel> cancelBooking(String bookingId, String reason);

  Future<bool> checkAvailability({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
  });

  Future<List<DateTime>> getBlockedDates(String propertyId);

  Future<Map<String, dynamic>> createPaymentIntent(String bookingId);

  Future<Map<String, dynamic>> payWithWallet(String bookingId);

  Future<void> simulateMockPayment(String providerIntentId);

  /// `POST /stays/bookings/occupants/upload-id` — returns `{ asset_id }`.
  Future<String> uploadOccupantIdDocument({
    required String filePath,
    required String side,
  });

  /// `POST /stays/bookings/:id/review`
  Future<void> submitBookingReview({
    required String bookingId,
    required int rating,
    String? comment,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  BookingRemoteDataSourceImpl({required this.client});
  final DioClient client;

  dynamic _unwrap(dynamic body) {
    if (body is Map) {
      final map = body is Map<String, dynamic>
          ? body
          : body.map((key, value) => MapEntry(key.toString(), value));
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

  BookingModel _mapBooking(Map<String, dynamic> json) {
    final checkIn = DateTime.tryParse((json['checkin_date'] ?? '').toString()) ??
        DateTime.now();
    final checkOut =
        DateTime.tryParse((json['checkout_date'] ?? '').toString()) ?? checkIn;
    final nights = (checkOut.difference(checkIn).inDays).clamp(1, 3650);
    final listingRaw = json['listing'];
    final listing = listingRaw is Map<String, dynamic>
        ? listingRaw
        : listingRaw is Map
            ? listingRaw.map((key, value) => MapEntry(key.toString(), value))
            : const <String, dynamic>{};
    final contact = _parseListingContact(listing);
    final subtotal = (json['total_subtotal'] as num?)?.toDouble() ?? 0;
    final guestFee = (json['guest_fee'] as num?)?.toDouble() ?? 0;
    final hostFee = (json['host_fee'] as num?)?.toDouble() ?? 0;
    final totalPaid = (json['total_paid'] as num?)?.toDouble() ?? subtotal + guestFee;
    final nightlyRate = nights > 0 ? subtotal / nights : subtotal;

    BookingStatus parseStatus(String s) {
      final key = s.trim().toLowerCase().replaceAll('-', '_');
      switch (key) {
        case 'payment_pending':
          return BookingStatus.paymentPending;
        case 'confirmed':
          return BookingStatus.confirmed;
        case 'active':
        case 'checked_in':
          return BookingStatus.active;
        case 'completed':
          return BookingStatus.completed;
        case 'cancelled':
        case 'cancelled_by_guest':
        case 'cancelled_by_host':
        case 'expired':
          return BookingStatus.cancelled;
        case 'rejected':
          return BookingStatus.rejected;
        case 'pending':
        case 'initiated':
          return BookingStatus.pending;
        default:
          return BookingStatus.pending;
      }
    }

    final occupants = json['occupants'];
    var guestName = (json['guest_name'] ?? '').toString().trim();
    if (guestName.isEmpty) {
      final guestRaw = json['guest'];
      if (guestRaw is Map) {
        final guestMap = guestRaw is Map<String, dynamic>
            ? guestRaw
            : guestRaw.map((key, value) => MapEntry(key.toString(), value));
        guestName = (guestMap['full_name'] ?? guestMap['name'] ?? '')
            .toString()
            .trim();
      }
    }
    if (guestName.isEmpty && occupants is List) {
      for (final item in occupants) {
        if (item is! Map) continue;
        final occupant = item is Map<String, dynamic>
            ? item
            : item.map((key, value) => MapEntry(key.toString(), value));
        final name = (occupant['full_name'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        final isPrimary = occupant['is_primary'] == true;
        if (isPrimary) {
          guestName = name;
          break;
        }
        guestName = guestName.isEmpty ? name : guestName;
      }
    }

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      propertyId: (json['listing_id'] ?? '').toString(),
      propertyName: (listing['title'] ?? '').toString(),
      propertyPhotoUrl: firstListingPhotoUrl({
        ...listing,
        if (listing['id'] == null && json['listing_id'] != null)
          'id': json['listing_id'],
      }),
      propertyCity: (listing['city'] ?? '').toString(),
      propertyNeighborhood: '',
      hostId: '',
      hostName: contact.hostName,
      guestId: '',
      guestName: guestName,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: (json['guest_count'] as num?)?.toInt() ?? 1,
      nightlyRate: nightlyRate,
      nights: nights,
      feeBreakdown: FeeBreakdownModel(
        nightlyRate: nightlyRate,
        nights: nights,
        subtotal: subtotal,
        guestServiceFee: guestFee,
        hostPlatformFee: hostFee,
        totalGuestPays: totalPaid,
        hostPayout: (json['payout_amount'] as num?)?.toDouble() ?? (subtotal - hostFee),
      ),
      status: parseStatus((json['status'] ?? 'pending').toString()),
      createdAt: DateTime.now(),
      checkInContact: contact.name,
      checkInContactPhone: contact.phone,
      checkInContactRole: contact.role,
      checkInInstructions: contact.instructions,
      exactAddress: contact.address,
    );
  }

  ({
    String name,
    String phone,
    String role,
    String instructions,
    String address,
    String hostName,
  }) _parseListingContact(Map<String, dynamic> listing) {
    final contactRaw = listing['check_in_contact'];
    var name = '';
    var phone = '';
    var role = '';
    var instructions = (listing['check_in_instructions'] ?? '').toString();

    if (contactRaw is Map<String, dynamic>) {
      name = (contactRaw['full_name'] ?? '').toString();
      phone = (contactRaw['phone'] ?? contactRaw['phone_encrypted'] ?? '')
          .toString();
      role = (contactRaw['role'] ?? '').toString();
      if (instructions.isEmpty) {
        instructions = (contactRaw['access_instructions'] ?? '').toString();
      }
    } else if (contactRaw is String) {
      name = contactRaw;
    }

    final addressRaw = listing['address'];
    final address = addressRaw == null || addressRaw.toString() == 'null'
        ? ''
        : addressRaw.toString();

    return (
      name: name,
      phone: phone,
      role: role,
      instructions: instructions,
      address: address,
      hostName: name,
    );
  }

  Future<String> _fetchListingPhotoUrl(String listingId) async {
    if (listingId.isEmpty) return '';
    try {
      final response = await client.get(ApiEndpoints.listingById(listingId));
      _assertSuccess(response.statusCode, response.data);
      final body = _unwrap(response.data);
      if (body is Map<String, dynamic>) {
        return firstListingPhotoUrl(body);
      }
    } catch (_) {
      // Best-effort — card shows placeholder if this fails.
    }
    return '';
  }

  Future<BookingModel> _withListingPhoto(BookingModel booking) async {
    if (booking.propertyPhotoUrl.isNotEmpty) return booking;
    final url = await _fetchListingPhotoUrl(booking.propertyId);
    if (url.isEmpty) return booking;
    return BookingModel.fromEntity(
      booking.copyWith(propertyPhotoUrl: url),
    );
  }

  Future<List<BookingModel>> _withListingPhotos(List<BookingModel> bookings) async {
    final photoCache = <String, String>{};
    final results = <BookingModel>[];

    for (final booking in bookings) {
      if (booking.propertyPhotoUrl.isNotEmpty) {
        results.add(booking);
        continue;
      }

      final listingId = booking.propertyId;
      if (listingId.isEmpty) {
        results.add(booking);
        continue;
      }

      final cached = photoCache[listingId];
      if (cached != null) {
        results.add(
          cached.isEmpty
              ? booking
              : BookingModel.fromEntity(
                  booking.copyWith(propertyPhotoUrl: cached),
                ),
        );
        continue;
      }

      final url = await _fetchListingPhotoUrl(listingId);
      photoCache[listingId] = url;
      results.add(
        url.isEmpty
            ? booking
            : BookingModel.fromEntity(
                booking.copyWith(propertyPhotoUrl: url),
              ),
      );
    }

    return results;
  }

  @override
  Future<BookingModel> createBooking({
    required String propertyId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    String? specialRequests,
    List<Map<String, dynamic>>? occupants,
  }) async {
    final response = await client.post(
      ApiEndpoints.staysBookings,
      data: {
        'listing_id': propertyId,
        'checkin_date': checkIn.toIso8601String().split('T').first,
        'checkout_date': checkOut.toIso8601String().split('T').first,
        'guest_count': guests,
        if (occupants != null && occupants.isNotEmpty) 'occupants': occupants,
      },
      options: Options(),
    );
    _assertSuccess(response.statusCode, response.data);
    final body = _unwrap(response.data);
    if (body is! Map<String, dynamic>) {
      throw const ServerException('Unexpected booking response');
    }
    return _withListingPhoto(_mapBooking(body));
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await client.get(ApiEndpoints.bookingById(bookingId));
    _assertSuccess(response.statusCode, response.data);
    final body = _unwrap(response.data);
    if (body is! Map<String, dynamic>) {
      throw const ServerException('Unexpected booking response');
    }
    return _withListingPhoto(_mapBooking(body));
  }

  @override
  Future<List<BookingModel>> getGuestBookings(String guestId) async {
    final response = await client.get(ApiEndpoints.staysBookings);
    _assertSuccess(response.statusCode, response.data);
    final body = _unwrap(response.data);
    if (body is! List) return const [];
    final bookings = <BookingModel>[];
    for (final item in body) {
      if (item is! Map) continue;
      final map = item is Map<String, dynamic>
          ? item
          : item.map((key, value) => MapEntry(key.toString(), value));
      bookings.add(_mapBooking(map));
    }
    return _withListingPhotos(bookings);
  }

  @override
  Future<List<BookingModel>> getHostBookings(String hostId) async {
    final response = await client.get(ApiEndpoints.staysHostBookings);
    _assertSuccess(response.statusCode, response.data);
    final body = _unwrap(response.data);
    if (body is! List) return const [];
    final bookings = <BookingModel>[];
    for (final item in body) {
      if (item is! Map) continue;
      final map = item is Map<String, dynamic>
          ? item
          : item.map((key, value) => MapEntry(key.toString(), value));
      bookings.add(_mapBooking(map));
    }
    return _withListingPhotos(bookings);
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, String reason) async {
    final response = await client.post(
      ApiEndpoints.cancelBookingById(bookingId),
      data: {'cancelled_by': 'guest', 'reason': reason},
      options: Options(),
    );
    _assertSuccess(response.statusCode, response.data);
    return getBookingById(bookingId);
  }

  @override
  Future<bool> checkAvailability({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final response = await client.get(
      ApiEndpoints.staysListingsSearch,
      queryParameters: {
        'checkin_date': checkIn.toIso8601String().split('T').first,
        'checkout_date': checkOut.toIso8601String().split('T').first,
      },
    );
    _assertSuccess(response.statusCode, response.data);
    final body = _unwrap(response.data);
    if (body is! List) return false;
    return body.whereType<Map<String, dynamic>>().any((l) => l['id'] == propertyId);
  }

  @override
  Future<List<DateTime>> getBlockedDates(String propertyId) async {
    return const [];
  }

  Map<String, dynamic> _unwrapMap(dynamic body) {
    final unwrapped = _unwrap(body);
    if (unwrapped is Map<String, dynamic>) return unwrapped;
    throw const ServerException('Unexpected response');
  }

  @override
  Future<Map<String, dynamic>> createPaymentIntent(String bookingId) async {
    final response = await client.post(
      ApiEndpoints.paymentIntentByBookingId(bookingId),
      data: const {},
      options: Options(),
    );
    _assertSuccess(response.statusCode, response.data);
    return _unwrapMap(response.data);
  }

  @override
  Future<void> simulateMockPayment(String providerIntentId) async {
    final response = await client.post(
      ApiEndpoints.mockPaymentWebhook(),
      data: {'provider_intent_id': providerIntentId},
      options: Options(),
    );
    _assertSuccess(response.statusCode, response.data);
  }

  @override
  Future<Map<String, dynamic>> payWithWallet(String bookingId) async {
    final response = await client.post(
      ApiEndpoints.paymentWalletByBookingId(bookingId),
      data: const {},
      options: Options(),
    );
    _assertSuccess(response.statusCode, response.data);
    return _unwrapMap(response.data);
  }

  @override
  Future<String> uploadOccupantIdDocument({
    required String filePath,
    required String side,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw ServerException('ID document file not found');
    }
    final response = await client.dio.post<Map<String, dynamic>>(
      ApiEndpoints.staysBookingOccupantUploadId,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(Platform.pathSeparator).last,
        ),
        'side': side == 'back' ? 'back' : 'front',
      }),
    );
    _assertSuccess(response.statusCode, response.data);
    final body = _unwrap(response.data);
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final assetId = (map['asset_id'] ?? map['id'])?.toString();
    if (assetId == null || assetId.isEmpty) {
      throw const ServerException('Upload did not return asset_id');
    }
    return assetId;
  }

  @override
  Future<void> submitBookingReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final response = await client.post(
      ApiEndpoints.bookingReviewById(bookingId),
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
      options: Options(),
    );
    _assertSuccess(response.statusCode, response.data);
  }
}
