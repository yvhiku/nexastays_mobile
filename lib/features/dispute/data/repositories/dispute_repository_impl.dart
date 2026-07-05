import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/repositories/dispute_repository.dart';
import '../datasources/dispute_remote_datasource.dart';
import '../models/dispute_model.dart';

// =============================================================================
// Dispute Repository Implementation
// =============================================================================

class DisputeRepositoryImpl implements DisputeRepository {
  DisputeRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });

  final DisputeRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;

  static const _disputePrefix = 'cached_dispute_';
  static const _bookingDisputeKey = 'dispute_for_booking_';
  static const _guestDisputesKey = 'guest_disputes_';

  /// Exposes the remote data source's upload progress stream.
  Stream<double> get uploadProgressStream =>
      remoteDataSource.uploadProgressStream;

  // ── Helpers ──────────────────────────────────────────────────────────

  Future<void> _cacheDispute(DisputeModel model) async {
    await localStorage.setString(
      '$_disputePrefix${model.id}',
      jsonEncode(model.toJson()),
    );
  }

  Future<DisputeModel?> _readCachedDispute(String disputeId) async {
    final raw = await localStorage.getString('$_disputePrefix$disputeId');
    if (raw == null || raw.isEmpty) return null;
    return DisputeModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  static String _typeToString(DisputeType t) => switch (t) {
        DisputeType.propertyNotAsDescribed => 'property_not_as_described',
        DisputeType.checkInIssue => 'check_in_issue',
        DisputeType.amenityMissing => 'amenity_missing',
        DisputeType.cleanlinessIssue => 'cleanliness_issue',
        DisputeType.safetyIssue => 'safety_issue',
        DisputeType.hostNoShow => 'host_no_show',
        DisputeType.unauthorisedCharge => 'unauthorised_charge',
        DisputeType.other => 'other',
      };

  // ── Open dispute ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Dispute>> openDispute({
    required String bookingId,
    required String propertyId,
    required String guestId,
    required DisputeType type,
    required String description,
    required List<String> evidencePaths,
  }) async {
    try {
      final model = await remoteDataSource.openDispute(
        bookingId: bookingId,
        propertyId: propertyId,
        guestId: guestId,
        type: _typeToString(type),
        description: description,
        evidencePaths: evidencePaths,
      );

      // Cache dispute and booking→dispute mapping.
      await _cacheDispute(model);
      await localStorage.setString(
        '$_bookingDisputeKey$bookingId',
        model.id,
      );

      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Get by dispute ID ────────────────────────────────────────────────

  @override
  Future<Either<Failure, Dispute>> getDisputeById(String disputeId) async {
    try {
      final model = await remoteDataSource.getDisputeById(disputeId);
      await _cacheDispute(model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      // Fallback to cache on network failure.
      final cached = await _readCachedDispute(disputeId);
      if (cached != null) return Right(cached);
      return const Left(NetworkFailure());
    }
  }

  // ── Get by booking ID ────────────────────────────────────────────────

  @override
  Future<Either<Failure, Dispute>> getDisputeByBookingId(
    String bookingId,
  ) async {
    try {
      // Check cache for booking→dispute mapping first.
      final cachedId = await localStorage.getString(
        '$_bookingDisputeKey$bookingId',
      );
      if (cachedId != null && cachedId.isNotEmpty) {
        return getDisputeById(cachedId);
      }

      final model = await remoteDataSource.getDisputeByBookingId(bookingId);

      // Cache.
      await _cacheDispute(model);
      await localStorage.setString(
        '$_bookingDisputeKey$bookingId',
        model.id,
      );

      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Get guest disputes ───────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Dispute>>> getGuestDisputes(
    String guestId,
  ) async {
    try {
      final models = await remoteDataSource.getGuestDisputes(guestId);

      // Cache individual disputes and the list.
      for (final model in models) {
        await _cacheDispute(model);
      }
      final jsonList = models.map((m) => m.toJson()).toList();
      await localStorage.setString(
        '$_guestDisputesKey$guestId',
        jsonEncode(jsonList),
      );

      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      // Fallback to cache.
      final raw = await localStorage.getString(
        '$_guestDisputesKey$guestId',
      );
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final cached = decoded
            .map((e) => DisputeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(cached);
      }
      return const Left(NetworkFailure());
    }
  }

  // ── Add evidence ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Dispute>> addEvidence({
    required String disputeId,
    required List<String> newEvidencePaths,
  }) async {
    try {
      final model = await remoteDataSource.addEvidence(
        disputeId: disputeId,
        newEvidencePaths: newEvidencePaths,
      );

      await _cacheDispute(model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }

  // ── Close dispute ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Dispute>> closeDispute(String disputeId) async {
    try {
      final model = await remoteDataSource.closeDispute(disputeId);
      await _cacheDispute(model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      return const Left(NetworkFailure());
    }
  }
}
