import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;
  final SecureStorageService secureStorage;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
    required this.secureStorage,
  });

  // ── Cache keys ──────────────────────────────────────────────────────────

  static const _guestBookingsPrefix = 'cached_guest_bookings_';
  static const _hostBookingsPrefix = 'cached_host_bookings_';
  static const _blockedDatesPrefix = 'blocked_dates_';
  static const _blockedDatesTsPrefix = 'blocked_dates_ts_';
  static const _blockedDatesTtl = Duration(minutes: 30);

  // ── createBooking ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Booking>> createBooking({
    required String propertyId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    String? specialRequests,
    List<Map<String, dynamic>> occupants = const [],
  }) async {
    try {
      final model = await remoteDataSource.createBooking(
        propertyId: propertyId,
        guestId: guestId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        specialRequests: specialRequests,
        occupants: occupants.isNotEmpty ? occupants : null,
      );

      // Invalidate cached guest bookings so the next fetch is fresh.
      await localStorage.remove('$_guestBookingsPrefix$guestId');

      return Right(model);
    } on ServerException catch (e) {
      if (e.message.toLowerCase().contains('unavailable')) {
        return const Left(
          ValidationFailure('Dates are no longer available'),
        );
      }
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      final nested = e.error;
      if (nested is AppException) {
        return Left(ServerFailure(nested.message));
      }
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getBookingById ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    try {
      final model = await remoteDataSource.getBookingById(bookingId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getGuestBookings ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Booking>>> getGuestBookings(
    String guestId,
  ) async {
    final cacheKey = '$_guestBookingsPrefix$guestId';

    try {
      final models = await remoteDataSource.getGuestBookings(guestId);

      // Cache as JSON string list.
      final jsonList =
          models.map((m) => jsonEncode(BookingModel.fromEntity(m).toJson())).toList();
      await localStorage.setStringList(cacheKey, jsonList);

      return Right(models.cast<Booking>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return _serveCachedBookings(cacheKey);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getHostBookings ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Booking>>> getHostBookings(
    String hostId,
  ) async {
    final cacheKey = '$_hostBookingsPrefix$hostId';

    try {
      final models = await remoteDataSource.getHostBookings(hostId);

      final jsonList =
          models.map((m) => jsonEncode(BookingModel.fromEntity(m).toJson())).toList();
      await localStorage.setStringList(cacheKey, jsonList);

      return Right(models.cast<Booking>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return _serveCachedBookings(cacheKey);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── cancelBooking ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Booking>> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final updated = await remoteDataSource.cancelBooking(bookingId, reason);

      // Update cached guest bookings list in-place if available.
      await _updateCachedBooking(updated);

      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── checkAvailability ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> checkAvailability({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      final available = await remoteDataSource.checkAvailability(
        propertyId: propertyId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
      return Right(available);
    } on ServerException catch (e) {
      if (e.message.toLowerCase().contains('unavailable')) {
        return const Left(
          ValidationFailure('Dates are no longer available'),
        );
      }
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getBlockedDates ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DateTime>>> getBlockedDates(
    String propertyId,
  ) async {
    final cacheKey = '$_blockedDatesPrefix$propertyId';
    final tsKey = '$_blockedDatesTsPrefix$propertyId';

    try {
      final dates = await remoteDataSource.getBlockedDates(propertyId);

      // Cache with a timestamp for TTL enforcement.
      final isoList = dates.map((d) => d.toIso8601String()).toList();
      await localStorage.setStringList(cacheKey, isoList);
      await localStorage.setString(tsKey, DateTime.now().toIso8601String());

      return Right(dates);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      // Serve from cache if within TTL.
      try {
        final tsStr = await localStorage.getString(tsKey);
        if (tsStr != null) {
          final cachedAt = DateTime.parse(tsStr);
          if (DateTime.now().difference(cachedAt) < _blockedDatesTtl) {
            final cached = await localStorage.getStringList(cacheKey);
            if (cached != null && cached.isNotEmpty) {
              return Right(cached.map(DateTime.parse).toList());
            }
          }
        }
      } catch (_) {
        // Cache read failed — fall through.
      }
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── completeBookingPayment ─────────────────────────────────────────────

  @override
  Future<Either<Failure, Booking>> completeBookingPayment(
    String bookingId,
  ) async {
    try {
      final intent = await remoteDataSource.createPaymentIntent(bookingId);
      final provider = (intent['provider'] ?? '').toString();
      final providerIntentId = intent['provider_intent_id'] as String?;

      if (provider == 'mock') {
        await remoteDataSource.simulateMockPayment(bookingId);
        final booking = await remoteDataSource.getBookingById(bookingId);
        return Right(booking);
      }

      final redirectUrl = intent['redirect_url'] as String?;
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final uri = Uri.parse(redirectUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        final booking = await remoteDataSource.getBookingById(bookingId);
        return Right(booking);
      }

      return Left(
        ServerFailure('Payment could not be started. Try again later.'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadOccupantIdDocument({
    required String filePath,
    required String side,
  }) async {
    try {
      final assetId = await remoteDataSource.uploadOccupantIdDocument(
        filePath: filePath,
        side: side,
      );
      return Right(assetId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitBookingReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      await remoteDataSource.submitBookingReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────

  /// Serves bookings from local cache; returns [CacheFailure] if unavailable.
  Future<Either<Failure, List<Booking>>> _serveCachedBookings(
    String cacheKey,
  ) async {
    try {
      final cached = await localStorage.getStringList(cacheKey);
      if (cached == null || cached.isEmpty) {
        return const Left(
          CacheFailure('No cached bookings available'),
        );
      }
      final bookings = cached
          .map((s) =>
              BookingModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .cast<Booking>()
          .toList();
      return Right(bookings);
    } catch (_) {
      return const Left(CacheFailure('Failed to read cached bookings'));
    }
  }

  /// Replaces a single booking inside the cached guest-bookings list.
  Future<void> _updateCachedBooking(BookingModel updated) async {
    final cacheKey = '$_guestBookingsPrefix${updated.guestId}';
    try {
      final cached = await localStorage.getStringList(cacheKey);
      if (cached == null) return;

      final updatedList = cached.map((s) {
        final map = jsonDecode(s) as Map<String, dynamic>;
        if (map['id'] == updated.id) {
          return jsonEncode(BookingModel.fromEntity(updated).toJson());
        }
        return s;
      }).toList();

      await localStorage.setStringList(cacheKey, updatedList);
    } catch (_) {
      // Silently ignore — cache update is best-effort.
    }
  }
}
