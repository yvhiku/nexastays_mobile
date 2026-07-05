// =============================================================================
// NexaStays Domain Failures (Clean Architecture)
// =============================================================================
// Failure types returned by repositories via Either<Failure, T>.
// Unlike exceptions (which are thrown), failures are values that flow through
// the functional error channel so the presentation layer can pattern-match
// on them without try/catch.
// =============================================================================

import 'package:equatable/equatable.dart';

/// Base failure class for the domain layer.
///
/// Extend this for each error category. Repositories return
/// `Either<Failure, T>` so use-cases and UI can react without exceptions.
abstract class Failure extends Equatable {
  const Failure(this.message);

  /// A user-friendly description of what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

// ── Concrete failures ───────────────────────────────────────────────────────

/// Remote server returned an error (5xx, unexpected response, etc.).
class ServerFailure extends Failure {
  const ServerFailure([
    String message = 'Something went wrong on our end. Please try again later.',
  ]) : super(message);
}

/// Device is offline or the server is unreachable.
class NetworkFailure extends Failure {
  const NetworkFailure([
    String message =
        'Unable to connect. Please check your internet connection.',
  ]) : super(message);
}

/// Local cache read / write failed.
class CacheFailure extends Failure {
  const CacheFailure([
    String message = 'Failed to access local data. Please try again.',
  ]) : super(message);
}

/// Authentication or authorisation error (expired token, wrong credentials).
class AuthFailure extends Failure {
  const AuthFailure([
    String message = 'Authentication failed. Please sign in again.',
  ]) : super(message);
}

/// Client-side input validation did not pass.
class ValidationFailure extends Failure {
  const ValidationFailure([
    String message = 'Please check the highlighted fields and try again.',
  ]) : super(message);
}
