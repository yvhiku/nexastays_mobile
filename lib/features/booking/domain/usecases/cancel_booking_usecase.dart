import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CancelBookingUseCase implements UseCase<Booking, CancelBookingParams> {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CancelBookingParams params) async {
    // ── Validation ────────────────────────────────────────────────────

    if (params.bookingId.isEmpty) {
      return const Left(ValidationFailure('Booking ID is required'));
    }

    if (params.reason.isEmpty) {
      return const Left(ValidationFailure('Please provide a reason'));
    }

    if (params.reason.length < 10) {
      return const Left(ValidationFailure('Please give a more detailed reason'));
    }

    // ── Orchestration ─────────────────────────────────────────────────

    return repository.cancelBooking(
      bookingId: params.bookingId,
      reason: params.reason,
    );
  }
}

class CancelBookingParams extends Equatable {
  final String bookingId;
  final String reason;

  const CancelBookingParams({
    required this.bookingId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bookingId, reason];
}
