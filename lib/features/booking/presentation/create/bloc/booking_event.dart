import 'package:equatable/equatable.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

// ── Initialization ──────────────────────────────────────────────────────────

class BookingInitialized extends BookingEvent {
  final String propertyId;
  final DateTime? preselectedCheckIn;
  final DateTime? preselectedCheckOut;
  final int preselectedGuests;

  const BookingInitialized({
    required this.propertyId,
    this.preselectedCheckIn,
    this.preselectedCheckOut,
    this.preselectedGuests = 1,
  });

  @override
  List<Object?> get props => [
        propertyId,
        preselectedCheckIn,
        preselectedCheckOut,
        preselectedGuests,
      ];
}

// ── Date selection ──────────────────────────────────────────────────────────

class BookingDatesSelected extends BookingEvent {
  final DateTime checkIn;
  final DateTime checkOut;

  const BookingDatesSelected({
    required this.checkIn,
    required this.checkOut,
  });

  @override
  List<Object?> get props => [checkIn, checkOut];
}

// ── Guest count ─────────────────────────────────────────────────────────────

class BookingGuestsChanged extends BookingEvent {
  final int count;

  const BookingGuestsChanged({required this.count});

  @override
  List<Object?> get props => [count];
}

// ── Special requests ────────────────────────────────────────────────────────

class BookingSpecialRequestsChanged extends BookingEvent {
  final String text;

  const BookingSpecialRequestsChanged({required this.text});

  @override
  List<Object?> get props => [text];
}

// ── Fee calculation ─────────────────────────────────────────────────────────

class BookingFeeCalculated extends BookingEvent {
  final double nightlyRate;
  final int nights;
  final double? weeklyDiscountPercent;

  const BookingFeeCalculated({
    required this.nightlyRate,
    required this.nights,
    this.weeklyDiscountPercent,
  });

  @override
  List<Object?> get props => [nightlyRate, nights, weeklyDiscountPercent];
}

// ── Submit / Confirm ────────────────────────────────────────────────────────

class BookingSubmitRequested extends BookingEvent {
  final String propertyId;
  final String guestId;
  final List<Map<String, dynamic>> occupants;

  const BookingSubmitRequested({
    required this.propertyId,
    required this.guestId,
    required this.occupants,
  });

  @override
  List<Object?> get props => [propertyId, guestId, occupants];
}

class BookingConfirmRequested extends BookingEvent {
  const BookingConfirmRequested();
}

// ── Cancellation ────────────────────────────────────────────────────────────

class BookingCancellationRequested extends BookingEvent {
  final String bookingId;
  final String reason;

  const BookingCancellationRequested({
    required this.bookingId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bookingId, reason];
}
