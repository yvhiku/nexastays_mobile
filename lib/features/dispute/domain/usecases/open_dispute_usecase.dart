import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dispute.dart';
import '../repositories/dispute_repository.dart';

// =============================================================================
// Open Dispute Use Case
// =============================================================================

/// Validates inputs and delegates to [DisputeRepository.openDispute].
class OpenDisputeUseCase extends UseCase<Dispute, OpenDisputeParams> {
  OpenDisputeUseCase(this._repository);

  final DisputeRepository _repository;

  @override
  Future<Either<Failure, Dispute>> call(OpenDisputeParams params) async {
    if (params.bookingId.isEmpty) {
      return const Left(ValidationFailure('Booking ID required'));
    }
    if (params.propertyId.isEmpty) {
      return const Left(ValidationFailure('Property ID required'));
    }
    if (params.guestId.isEmpty) {
      return const Left(ValidationFailure('User not authenticated'));
    }
    if (params.description.isEmpty) {
      return const Left(ValidationFailure('Please describe the issue'));
    }
    if (params.description.length < 20) {
      return const Left(ValidationFailure(
        'Please provide more detail (at least 20 characters)',
      ));
    }

    return _repository.openDispute(
      bookingId: params.bookingId,
      propertyId: params.propertyId,
      guestId: params.guestId,
      type: params.type,
      description: params.description,
      evidencePaths: params.evidencePaths,
    );
  }
}

// =============================================================================
// Params
// =============================================================================

class OpenDisputeParams extends Equatable {
  const OpenDisputeParams({
    required this.bookingId,
    required this.propertyId,
    required this.guestId,
    required this.type,
    required this.description,
    this.evidencePaths = const [],
  });

  final String bookingId;
  final String propertyId;
  final String guestId;
  final DisputeType type;
  final String description;

  /// Local file paths for uploaded evidence (photos/videos).
  final List<String> evidencePaths;

  @override
  List<Object?> get props => [
        bookingId,
        propertyId,
        guestId,
        type,
        description,
        evidencePaths,
      ];
}
