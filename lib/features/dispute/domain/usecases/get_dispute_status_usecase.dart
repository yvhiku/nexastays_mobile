import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dispute.dart';
import '../repositories/dispute_repository.dart';

// =============================================================================
// Get Dispute Status Use Case
// =============================================================================

/// Fetches a dispute by either [disputeId] or [bookingId].
///
/// At least one identifier must be provided. If both are given,
/// [disputeId] takes priority.
class GetDisputeStatusUseCase extends UseCase<Dispute, GetDisputeParams> {
  GetDisputeStatusUseCase(this._repository);

  final DisputeRepository _repository;

  @override
  Future<Either<Failure, Dispute>> call(GetDisputeParams params) async {
    if (params.disputeId == null && params.bookingId == null) {
      return const Left(
        ValidationFailure('Dispute ID or Booking ID required'),
      );
    }

    if (params.disputeId != null) {
      return _repository.getDisputeById(params.disputeId!);
    }

    return _repository.getDisputeByBookingId(params.bookingId!);
  }
}

// =============================================================================
// Params
// =============================================================================

class GetDisputeParams extends Equatable {
  const GetDisputeParams({
    this.disputeId,
    this.bookingId,
  });

  /// Fetch by dispute ID (takes priority if both are provided).
  final String? disputeId;

  /// Fetch by booking ID (used as fallback).
  final String? bookingId;

  @override
  List<Object?> get props => [disputeId, bookingId];
}
