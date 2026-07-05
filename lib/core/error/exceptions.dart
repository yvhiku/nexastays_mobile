// =============================================================================
// NexaStays Custom Exceptions
// =============================================================================
// Typed domain exceptions used across the app. The network layer maps HTTP
// status codes to these types; the presentation layer maps them to
// user-friendly messages.
// =============================================================================

/// Base exception for all NexaStays domain errors.
///
/// Every subclass carries a human-readable [message] and an optional
/// machine-readable [code] for logging / analytics.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  /// A user-friendly description of what went wrong.
  final String message;

  /// Optional error code for logging, analytics, or conditional handling.
  final String? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

// ── HTTP status-code exceptions ─────────────────────────────────────────────

/// 400 — The request was malformed or contained invalid data.
class BadRequestException extends AppException {
  const BadRequestException([
    String message =
        'The request could not be processed. Please check your input.',
    String? code,
  ]) : super(message, code: code ?? 'BAD_REQUEST');
}

/// 401 — Authentication is required or has expired.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'Your session has expired. Please sign in again.',
    String? code,
  ]) : super(message, code: code ?? 'UNAUTHORIZED');
}

/// 403 — The authenticated user lacks permission.
class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'You do not have permission to perform this action.',
    String? code,
  ]) : super(message, code: code ?? 'FORBIDDEN');
}

/// 404 — The requested resource was not found.
class NotFoundException extends AppException {
  const NotFoundException([
    String message = 'The requested resource could not be found.',
    String? code,
  ]) : super(message, code: code ?? 'NOT_FOUND');
}

/// 500+ — An unexpected error occurred on the server.
class ServerException extends AppException {
  const ServerException([
    String message = 'Something went wrong on our end. Please try again later.',
    String? code,
  ]) : super(message, code: code ?? 'SERVER_ERROR');
}

// ── Connectivity exceptions ─────────────────────────────────────────────────

/// No internet connection or server unreachable (SocketException).
class NetworkException extends AppException {
  const NetworkException([
    String message =
        'Unable to connect. Please check your internet connection.',
    String? code,
  ]) : super(message, code: code ?? 'NETWORK_ERROR');
}

/// The request took too long to complete.
class TimeoutException extends AppException {
  const TimeoutException([
    String message = 'The request timed out. Please try again.',
    String? code,
  ]) : super(message, code: code ?? 'TIMEOUT');
}

// ── Local / cache exceptions ────────────────────────────────────────────────

/// A read or write to local storage / cache failed.
class CacheException extends AppException {
  const CacheException([
    String message = 'Failed to access local data. Please try again.',
    String? code,
  ]) : super(message, code: code ?? 'CACHE_ERROR');
}

// ── Catch-all ───────────────────────────────────────────────────────────────

/// Unmapped / unexpected errors.
class UnknownException extends AppException {
  const UnknownException([
    String message = 'An unexpected error occurred. Please try again.',
    String? code,
  ]) : super(message, code: code ?? 'UNKNOWN');
}
