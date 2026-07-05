import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dispute.dart';

// =============================================================================
// Dispute Repository (Abstract Interface)
// =============================================================================

/// Contract for dispute operations.
///
/// All methods return `Future<Either<Failure, T>>` so use-cases and the
/// presentation layer can react without exceptions.
abstract class DisputeRepository {
  /// Opens a new dispute for a booking.
  ///
  /// [evidencePaths] contains local file paths that will be uploaded.
  Future<Either<Failure, Dispute>> openDispute({
    required String bookingId,
    required String propertyId,
    required String guestId,
    required DisputeType type,
    required String description,
    required List<String> evidencePaths,
  });

  /// Fetches a single dispute by its [disputeId].
  Future<Either<Failure, Dispute>> getDisputeById(String disputeId);

  /// Fetches the dispute associated with a [bookingId] (if any).
  Future<Either<Failure, Dispute>> getDisputeByBookingId(String bookingId);

  /// Returns all disputes filed by the given [guestId].
  Future<Either<Failure, List<Dispute>>> getGuestDisputes(String guestId);

  /// Appends additional evidence to an existing dispute.
  Future<Either<Failure, Dispute>> addEvidence({
    required String disputeId,
    required List<String> newEvidencePaths,
  });

  /// Closes a dispute from the guest side (e.g. issue was resolved).
  Future<Either<Failure, Dispute>> closeDispute(String disputeId);
}
