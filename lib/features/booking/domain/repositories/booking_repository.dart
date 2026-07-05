import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking({
    required String propertyId,
    required String guestId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    String? specialRequests,
    List<Map<String, dynamic>> occupants = const [],
  });

  Future<Either<Failure, Booking>> getBookingById(String bookingId);

  Future<Either<Failure, List<Booking>>> getGuestBookings(String guestId);

  Future<Either<Failure, List<Booking>>> getHostBookings(String hostId);

  Future<Either<Failure, Booking>> cancelBooking({
    required String bookingId,
    required String reason,
  });

  Future<Either<Failure, bool>> checkAvailability({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
  });

  Future<Either<Failure, List<DateTime>>> getBlockedDates(
    String propertyId,
  );

  Future<Either<Failure, Booking>> completeBookingPayment(String bookingId);

  Future<Either<Failure, String>> uploadOccupantIdDocument({
    required String filePath,
    required String side,
  });

  Future<Either<Failure, void>> submitBookingReview({
    required String bookingId,
    required int rating,
    String? comment,
  });
}
