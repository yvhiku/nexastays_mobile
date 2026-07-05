import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dispute_model.dart';

// =============================================================================
// Dispute Remote Data Source
// =============================================================================

/// Contract for dispute API calls.
abstract class DisputeRemoteDataSource {
  /// Opens a new dispute via `POST /disputes`.
  Future<DisputeModel> openDispute({
    required String bookingId,
    required String propertyId,
    required String guestId,
    required String type,
    required String description,
    required List<String> evidencePaths,
  });

  /// Fetches a dispute by ID via `GET /disputes/:disputeId`.
  Future<DisputeModel> getDisputeById(String disputeId);

  /// Fetches the dispute for a booking via `GET /disputes?booking_id=...`.
  Future<DisputeModel> getDisputeByBookingId(String bookingId);

  /// Returns all disputes for a guest via `GET /disputes?guest_id=...`.
  Future<List<DisputeModel>> getGuestDisputes(String guestId);

  /// Uploads additional evidence via `POST /disputes/:disputeId/evidence`.
  Future<DisputeModel> addEvidence({
    required String disputeId,
    required List<String> newEvidencePaths,
  });

  /// Guest-initiated close via `PATCH /disputes/:disputeId/close`.
  Future<DisputeModel> closeDispute(String disputeId);

  /// Emits upload progress from 0.0 to 1.0 during evidence uploads.
  Stream<double> get uploadProgressStream;
}

// =============================================================================
// Implementation
// =============================================================================

class DisputeRemoteDataSourceImpl implements DisputeRemoteDataSource {
  DisputeRemoteDataSourceImpl(this._client);

  final DioClient _client;

  final StreamController<double> _uploadProgress =
      StreamController<double>.broadcast();

  @override
  Stream<double> get uploadProgressStream => _uploadProgress.stream;

  // ── Helpers ──────────────────────────────────────────────────────────

  void _onSendProgress(int sent, int total) {
    if (total > 0) {
      _uploadProgress.add(sent / total);
    }
  }

  Never _throwOnError(DioException e) {
    final message =
        e.response?.data?['message'] as String? ?? e.message ?? 'Server error';
    throw ServerException(message);
  }

  // ── Open dispute ─────────────────────────────────────────────────────

  @override
  Future<DisputeModel> openDispute({
    required String bookingId,
    required String propertyId,
    required String guestId,
    required String type,
    required String description,
    required List<String> evidencePaths,
  }) async {
    try {
      late final Response response;

      if (evidencePaths.isNotEmpty) {
        final formData = FormData.fromMap({
          'booking_id': bookingId,
          'property_id': propertyId,
          'guest_id': guestId,
          'type': type,
          'description': description,
          'evidence': await Future.wait(
            evidencePaths.map(
              (path) => MultipartFile.fromFile(path),
            ),
          ),
        });

        response = await _client.dio.post(
          ApiEndpoints.disputes,
          data: formData,
          onSendProgress: _onSendProgress,
        );
      } else {
        response = await _client.dio.post(
          ApiEndpoints.disputes,
          data: {
            'booking_id': bookingId,
            'property_id': propertyId,
            'guest_id': guestId,
            'type': type,
            'description': description,
          },
        );
      }

      return DisputeModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Get by ID ────────────────────────────────────────────────────────

  @override
  Future<DisputeModel> getDisputeById(String disputeId) async {
    try {
      final response = await _client.get(ApiEndpoints.disputeById(disputeId));
      return DisputeModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Get by booking ID ────────────────────────────────────────────────

  @override
  Future<DisputeModel> getDisputeByBookingId(String bookingId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.disputes,
        queryParameters: {'booking_id': bookingId},
      );

      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        throw const ServerException('No dispute found for this booking');
      }

      return DisputeModel.fromJson(data[0] as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Get guest disputes ───────────────────────────────────────────────

  @override
  Future<List<DisputeModel>> getGuestDisputes(String guestId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.disputes,
        queryParameters: {
          'guest_id': guestId,
          'sort': 'opened_at_desc',
        },
      );

      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => DisputeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Add evidence ─────────────────────────────────────────────────────

  @override
  Future<DisputeModel> addEvidence({
    required String disputeId,
    required List<String> newEvidencePaths,
  }) async {
    try {
      final formData = FormData.fromMap({
        'files': await Future.wait(
          newEvidencePaths.map(
            (path) => MultipartFile.fromFile(path),
          ),
        ),
      });

      final response = await _client.dio.post(
        ApiEndpoints.disputeEvidence(disputeId),
        data: formData,
        onSendProgress: _onSendProgress,
      );

      return DisputeModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }

  // ── Close dispute ────────────────────────────────────────────────────

  @override
  Future<DisputeModel> closeDispute(String disputeId) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.disputeClose(disputeId),
        data: <String, dynamic>{},
      );

      return DisputeModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _throwOnError(e);
    }
  }
}
