// =============================================================================
// NexaStays Base Use Case (Clean Architecture)
// =============================================================================
// Every use case in the app extends this contract. Repositories return
// Either<Failure, T> and use cases forward that result to the presentation
// layer (Riverpod providers / controllers).
// =============================================================================

import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Contract for a single-responsibility use case.
///
/// [Type]   — the success value returned on the right side of [Either].
/// [Params] — the input parameters; use [NoParams] when none are needed.
///
/// ```dart
/// class GetPropertyById extends UseCase<Property, PropertyParams> {
///   @override
///   Future<Either<Failure, Property>> call(PropertyParams params) { ... }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker class for use cases that require no input parameters.
///
/// ```dart
/// class GetFeaturedListings extends UseCase<List<Property>, NoParams> {
///   @override
///   Future<Either<Failure, List<Property>>> call(NoParams _) { ... }
/// }
///
/// // Invocation:
/// final result = await getFeaturedListings(NoParams());
/// ```
class NoParams {
  const NoParams();
}
