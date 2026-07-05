// =============================================================================
// NexaStays Error Interceptor
// =============================================================================
// Converts raw Dio / HTTP errors into typed domain exceptions so the rest of
// the app never deals with status codes directly.
// =============================================================================

import 'dart:async' as async;
import 'dart:io';

import 'package:dio/dio.dart';



import '../../error/exceptions.dart';

/// Maps [DioException] instances to domain-specific [AppException] subtypes.
///
/// Attach this interceptor to [Dio] **after** [AuthInterceptor] so that
/// 401 token-refresh logic runs first.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  // ── Exception mapper ────────────────────────────────────────────────

  /// Converts a [DioException] into the appropriate [AppException].
  AppException _mapException(DioException err) {
    // ── Connection / timeout errors ─────────────────────────────────
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const UnknownException('The request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Secure connection failed. Please try again.',
        );

      // badResponse — map by status code below.
      case DioExceptionType.badResponse:
        return _mapStatusCode(err);

      case DioExceptionType.unknown:
      default:
        return _mapUnknown(err);
    }
  }

  // ── Status-code mapping ─────────────────────────────────────────────

  AppException _mapStatusCode(DioException err) {
    final statusCode = err.response?.statusCode;
    final serverMessage = _extractServerMessage(err.response);

    switch (statusCode) {
      case 400:
        return BadRequestException(
          serverMessage ??
              'The request could not be processed. Please check your input.',
        );
      case 401:
        return UnauthorizedException(
          serverMessage ?? 'Your session has expired. Please sign in again.',
        );
      case 403:
        return ForbiddenException(
          serverMessage ?? 'You do not have permission to perform this action.',
        );
      case 404:
        return NotFoundException(
          serverMessage ?? 'The requested resource could not be found.',
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          serverMessage ??
              'Something went wrong on our end. Please try again later.',
        );
      default:
        return UnknownException(
          serverMessage ?? 'Unexpected error (HTTP $statusCode).',
        );
    }
  }

  // ── Unknown / socket errors ─────────────────────────────────────────

  AppException _mapUnknown(DioException err) {
    final inner = err.error;

    if (inner is SocketException) {
      return const NetworkException();
    }

    if (inner is async.TimeoutException) {
      return const TimeoutException();
    }

    return const UnknownException();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Attempts to extract a human-readable `message` field from the server
  /// response body (assumes JSON `{ "message": "..." }`).
  String? _extractServerMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String?;
      }
    } catch (_) {
      // Ignore parse errors — fall back to default messages.
    }
    return null;
  }
}
