import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/session/session_manager.dart';
import '../../../../property/domain/entities/property.dart';
import '../../../../property/domain/repositories/property_repository.dart';
import '../../../domain/entities/fee_breakdown.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/usecases/cancel_booking_usecase.dart';
import '../../../domain/usecases/create_booking_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase createBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final BookingRepository bookingRepository;
  final PropertyRepository propertyRepository;
  final SessionManager sessionManager;

  BookingBloc({
    required this.createBookingUseCase,
    required this.cancelBookingUseCase,
    required this.bookingRepository,
    required this.propertyRepository,
    required this.sessionManager,
  }) : super(const BookingInitial()) {
    on<BookingInitialized>(_onInitialized);
    on<BookingDatesSelected>(_onDatesSelected);
    on<BookingGuestsChanged>(_onGuestsChanged);
    on<BookingSpecialRequestsChanged>(_onSpecialRequestsChanged);
    on<BookingSubmitRequested>(_onSubmitRequested);
    on<BookingConfirmRequested>(_onConfirmRequested);
    on<BookingCancellationRequested>(_onCancellationRequested);
  }

  // ── BookingInitialized ──────────────────────────────────────────────────

  Future<void> _onInitialized(
    BookingInitialized event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingInitial());

    // Fetch property and blocked dates in parallel.
    final results = await Future.wait([
      propertyRepository.getPropertyById(event.propertyId),
      bookingRepository.getBlockedDates(event.propertyId),
    ]);

    final propertyResult = results[0] as Either<Failure, Property>;
    final blockedDatesResult = results[1] as Either<Failure, List<DateTime>>;

    // Handle property fetch failure.
    if (propertyResult.isLeft()) {
      final failure = propertyResult.fold((f) => f, (_) => null)!;
      emit(BookingError(message: failure.message));
      return;
    }

    final property = propertyResult.fold((_) => null, (p) => p)!;

    // Blocked dates — fallback to empty list on failure.
    final blockedDates = blockedDatesResult.fold(
      (_) => <DateTime>[],
      (dates) => dates,
    );

    // Pre-compute fee if dates are preselected.
    FeeBreakdown? feeBreakdown;
    if (event.preselectedCheckIn != null &&
        event.preselectedCheckOut != null) {
      final nights = event.preselectedCheckOut!
          .difference(event.preselectedCheckIn!)
          .inDays;
      if (nights > 0) {
        feeBreakdown = FeeBreakdown.calculate(
          nightlyRate: property.nightlyRate,
          nights: nights,
          weeklyDiscountPercent: property.weeklyDiscount,
          monthlyDiscountPercent: property.monthlyDiscount,
        );
      }
    }

    emit(BookingFormReady(
      property: property,
      blockedDates: blockedDates,
      selectedCheckIn: event.preselectedCheckIn,
      selectedCheckOut: event.preselectedCheckOut,
      selectedGuests: event.preselectedGuests,
      feeBreakdown: feeBreakdown,
      datesAvailable: true,
      isCheckingAvail: false,
    ));
  }

  // ── BookingDatesSelected ────────────────────────────────────────────────

  Future<void> _onDatesSelected(
    BookingDatesSelected event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    if (current is! BookingFormReady) return;

    // Validate dates are not in blocked list.
    final checkInDay = DateTime(
      event.checkIn.year,
      event.checkIn.month,
      event.checkIn.day,
    );
    final isBlocked = current.blockedDates.any((d) =>
        d.year == checkInDay.year &&
        d.month == checkInDay.month &&
        d.day == checkInDay.day);
    if (isBlocked) {
      emit(BookingError(
        message: 'Selected dates include blocked dates',
        isDatesUnavailable: true,
      ));
      return;
    }

    emit(current.copyWith(isCheckingAvail: true));

    final result = await bookingRepository.checkAvailability(
      propertyId: current.property.id,
      checkIn: event.checkIn,
      checkOut: event.checkOut,
    );

    result.fold(
      (failure) {
        emit(BookingError(message: failure.message));
      },
      (isAvailable) {
        if (isAvailable) {
          final nights =
              event.checkOut.difference(event.checkIn).inDays;
          final feeBreakdown = FeeBreakdown.calculate(
            nightlyRate: current.property.nightlyRate,
            nights: nights,
            weeklyDiscountPercent: current.property.weeklyDiscount,
            monthlyDiscountPercent: current.property.monthlyDiscount,
          );
          emit(current.copyWith(
            selectedCheckIn: event.checkIn,
            selectedCheckOut: event.checkOut,
            feeBreakdown: feeBreakdown,
            datesAvailable: true,
            isCheckingAvail: false,
          ));
        } else {
          emit(current.copyWith(
            datesAvailable: false,
            isCheckingAvail: false,
          ));
        }
      },
    );
  }

  // ── BookingGuestsChanged ────────────────────────────────────────────────

  void _onGuestsChanged(
    BookingGuestsChanged event,
    Emitter<BookingState> emit,
  ) {
    final current = state;
    if (current is! BookingFormReady) return;

    // Clamp to property max.
    final clamped = event.count.clamp(1, current.property.maxGuests);
    emit(current.copyWith(selectedGuests: clamped));
  }

  // ── BookingSpecialRequestsChanged ──────────────────────────────────────

  void _onSpecialRequestsChanged(
    BookingSpecialRequestsChanged event,
    Emitter<BookingState> emit,
  ) {
    final current = state;
    if (current is! BookingFormReady) return;

    emit(current.copyWith(specialRequests: event.text));
  }

  // ── BookingSubmitRequested ──────────────────────────────────────────────

  void _onSubmitRequested(
    BookingSubmitRequested event,
    Emitter<BookingState> emit,
  ) {
    final current = state;
    if (current is! BookingFormReady) return;
    if (current.feeBreakdown == null) return;
    if (!current.datesAvailable) return;
    if (event.occupants.isEmpty) return;

    emit(BookingConfirmationReady(
      property: current.property,
      feeBreakdown: current.feeBreakdown!,
      checkIn: current.selectedCheckIn!,
      checkOut: current.selectedCheckOut!,
      guests: current.selectedGuests,
      specialRequests: current.specialRequests,
      occupants: event.occupants,
    ));
  }

  // ── BookingConfirmRequested ─────────────────────────────────────────────

  Future<void> _onConfirmRequested(
    BookingConfirmRequested event,
    Emitter<BookingState> emit,
  ) async {
    final current = state;
    if (current is! BookingConfirmationReady) return;

    emit(const BookingSubmitting());

    final result = await createBookingUseCase(CreateBookingParams(
      propertyId: current.property.id,
      guestId: sessionManager.userId!,
      checkIn: current.checkIn,
      checkOut: current.checkOut,
      guests: current.guests,
      specialRequests: current.specialRequests.isNotEmpty
          ? current.specialRequests
          : null,
      occupants: current.occupants,
    ));

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => null)!;
      final isDatesUnavail =
          failure is ValidationFailure &&
          failure.message.toLowerCase().contains('unavailable');
      emit(BookingError(
        message: failure.message,
        isDatesUnavailable: isDatesUnavail,
      ));
      return;
    }

    final booking = result.fold((_) => null, (b) => b)!;
    final payResult =
        await bookingRepository.completeBookingPayment(booking.id);
    payResult.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (paidBooking) => emit(BookingSuccess(booking: paidBooking)),
    );
  }

  // ── BookingCancellationRequested ────────────────────────────────────────

  Future<void> _onCancellationRequested(
    BookingCancellationRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingCancelling());

    final result = await cancelBookingUseCase(CancelBookingParams(
      bookingId: event.bookingId,
      reason: event.reason,
    ));

    result.fold(
      (failure) {
        emit(BookingError(message: failure.message));
      },
      (_) {
        emit(BookingCancelled(bookingId: event.bookingId));
      },
    );
  }
}
