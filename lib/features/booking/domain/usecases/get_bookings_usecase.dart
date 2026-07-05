import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

enum BookingRole { guest, host }

class GetBookingsUseCase implements UseCase<List<Booking>, GetBookingsParams> {
  final BookingRepository repository;

  GetBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(GetBookingsParams params) async {
    // ── Validation ────────────────────────────────────────────────────

    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    // ── Orchestration ─────────────────────────────────────────────────

    if (params.role == BookingRole.guest) {
      return repository.getGuestBookings(params.userId);
    } else {
      return repository.getHostBookings(params.userId);
    }
  }
}

class GetBookingsParams extends Equatable {
  final String userId;
  final BookingRole role;

  const GetBookingsParams({
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}
