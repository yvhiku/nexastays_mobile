import 'package:equatable/equatable.dart';

import '../../../domain/entities/booking.dart';
import '../../../../property/domain/entities/property.dart';
import '../../../domain/entities/fee_breakdown.dart';

sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

// ── Initial ─────────────────────────────────────────────────────────────────

class BookingInitial extends BookingState {
  const BookingInitial();
}

// ── Form ready ──────────────────────────────────────────────────────────────

class BookingFormReady extends BookingState {
  final Property property;
  final DateTime? selectedCheckIn;
  final DateTime? selectedCheckOut;
  final int selectedGuests;
  final List<DateTime> blockedDates;
  final FeeBreakdown? feeBreakdown;
  final String specialRequests;
  final bool datesAvailable;
  final bool isCheckingAvail;

  const BookingFormReady({
    required this.property,
    this.selectedCheckIn,
    this.selectedCheckOut,
    this.selectedGuests = 1,
    this.blockedDates = const [],
    this.feeBreakdown,
    this.specialRequests = '',
    this.datesAvailable = true,
    this.isCheckingAvail = false,
  });

  BookingFormReady copyWith({
    Property? property,
    DateTime? selectedCheckIn,
    DateTime? selectedCheckOut,
    int? selectedGuests,
    List<DateTime>? blockedDates,
    FeeBreakdown? feeBreakdown,
    String? specialRequests,
    bool? datesAvailable,
    bool? isCheckingAvail,
  }) {
    return BookingFormReady(
      property: property ?? this.property,
      selectedCheckIn: selectedCheckIn ?? this.selectedCheckIn,
      selectedCheckOut: selectedCheckOut ?? this.selectedCheckOut,
      selectedGuests: selectedGuests ?? this.selectedGuests,
      blockedDates: blockedDates ?? this.blockedDates,
      feeBreakdown: feeBreakdown ?? this.feeBreakdown,
      specialRequests: specialRequests ?? this.specialRequests,
      datesAvailable: datesAvailable ?? this.datesAvailable,
      isCheckingAvail: isCheckingAvail ?? this.isCheckingAvail,
    );
  }

  @override
  List<Object?> get props => [
        property,
        selectedCheckIn,
        selectedCheckOut,
        selectedGuests,
        blockedDates,
        feeBreakdown,
        specialRequests,
        datesAvailable,
        isCheckingAvail,
      ];
}

// ── Submitting ──────────────────────────────────────────────────────────────

class BookingSubmitting extends BookingState {
  const BookingSubmitting();
}

// ── Confirmation ready ──────────────────────────────────────────────────────

class BookingConfirmationReady extends BookingState {
  final Property property;
  final FeeBreakdown feeBreakdown;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String specialRequests;
  final List<Map<String, dynamic>> occupants;

  const BookingConfirmationReady({
    required this.property,
    required this.feeBreakdown,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.specialRequests = '',
    this.occupants = const [],
  });

  @override
  List<Object?> get props => [
        property,
        feeBreakdown,
        checkIn,
        checkOut,
        guests,
        specialRequests,
        occupants,
      ];
}

// ── Success ─────────────────────────────────────────────────────────────────

class BookingSuccess extends BookingState {
  final Booking booking;

  const BookingSuccess({required this.booking});

  @override
  List<Object?> get props => [booking];
}

// ── Cancelling ──────────────────────────────────────────────────────────────

class BookingCancelling extends BookingState {
  const BookingCancelling();
}

// ── Cancelled ───────────────────────────────────────────────────────────────

class BookingCancelled extends BookingState {
  final String bookingId;

  const BookingCancelled({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

// ── Error ───────────────────────────────────────────────────────────────────

class BookingError extends BookingState {
  final String message;
  final bool isDatesUnavailable;

  const BookingError({
    required this.message,
    this.isDatesUnavailable = false,
  });

  @override
  List<Object?> get props => [message, isDatesUnavailable];
}
