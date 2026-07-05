import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase implements UseCase<Booking, CreateBookingParams> {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CreateBookingParams params) async {
    // ── Input Validation ──────────────────────────────────────────────

    if (params.propertyId.isEmpty) {
      return const Left(ValidationFailure('Property ID is required'));
    }
    
    if (params.guestId.isEmpty) {
      return const Left(ValidationFailure('Guest ID is required'));
    }

    final now = DateTime.now();
    // Use start of day for comparison to allow booking for today
    final today = DateTime(now.year, now.month, now.day);
    if (params.checkIn.isBefore(today)) {
      return const Left(ValidationFailure('Check-in date must be in the future'));
    }

    if (!params.checkOut.isAfter(params.checkIn)) {
      return const Left(ValidationFailure('Check-out must be after check-in'));
    }

    final nights = params.checkOut.difference(params.checkIn).inDays;
    if (nights < 1) {
      return const Left(ValidationFailure('Stay must be at least 1 night'));
    }

    if (params.guests < 1) {
      return const Left(ValidationFailure('At least 1 guest required'));
    }

    // ── Orchestration ─────────────────────────────────────────────────

    // 1. Check availability first
    final availabilityResult = await repository.checkAvailability(
      propertyId: params.propertyId,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
    );

    return availabilityResult.fold(
      (failure) => Left(failure),
      (isAvailable) async {
        if (!isAvailable) {
          return const Left(ValidationFailure('These dates are no longer available'));
        }

        // 2. Delegate to repository to create booking
        return repository.createBooking(
          propertyId: params.propertyId,
          guestId: params.guestId,
          checkIn: params.checkIn,
          checkOut: params.checkOut,
          guests: params.guests,
          specialRequests: params.specialRequests,
          occupants: params.occupants,
        );
      },
    );
  }
}

class CreateBookingParams extends Equatable {
  final String propertyId;
  final String guestId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String? specialRequests;
  final List<Map<String, dynamic>> occupants;

  const CreateBookingParams({
    required this.propertyId,
    required this.guestId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.specialRequests,
    this.occupants = const [],
  });

  @override
  List<Object?> get props => [
        propertyId,
        guestId,
        checkIn,
        checkOut,
        guests,
        specialRequests,
        occupants,
      ];
}
