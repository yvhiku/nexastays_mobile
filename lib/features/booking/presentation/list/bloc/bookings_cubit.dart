import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/session/session_manager.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/usecases/cancel_booking_usecase.dart';
import '../../../domain/usecases/get_bookings_usecase.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final GetBookingsUseCase _getBookingsUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;
  final SessionManager _sessionManager;

  BookingsCubit({
    required GetBookingsUseCase getBookingsUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    required SessionManager sessionManager,
  })  : _getBookingsUseCase = getBookingsUseCase,
        _cancelBookingUseCase = cancelBookingUseCase,
        _sessionManager = sessionManager,
        super(const BookingsInitial());

  Future<void> loadBookings() async {
    emit(const BookingsLoading());

    final userId = _sessionManager.userId;
    if (userId == null) {
      emit(const BookingsError(message: 'User session not found'));
      return;
    }

    final result = await _getBookingsUseCase(GetBookingsParams(
      userId: userId,
      role: BookingRole.guest,
    ));

    result.fold(
      (failure) => emit(BookingsError(message: failure.message)),
      (bookings) {
        final upcomingBookings = bookings.where((b) {
          return b.status == BookingStatus.paymentPending ||
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.active;
        }).toList()
          ..sort((a, b) => a.checkIn.compareTo(b.checkIn));

        final pastBookings = bookings.where((b) {
          return b.status == BookingStatus.completed ||
              b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.rejected;
        }).toList()
          ..sort((a, b) => b.checkIn.compareTo(a.checkIn));

        if (upcomingBookings.isEmpty && pastBookings.isEmpty) {
          emit(const BookingsEmpty(tab: BookingsTab.upcoming));
        } else {
          emit(BookingsLoaded(
            upcomingBookings: upcomingBookings,
            pastBookings: pastBookings,
            activeTab: BookingsTab.upcoming,
          ));
        }
      },
    );
  }

  void switchTab(BookingsTab tab) {
    if (state is BookingsLoaded) {
      final currentState = state as BookingsLoaded;

      // Early exit if the tab hasn't actually changed
      if (currentState.activeTab == tab) return;

      emit(BookingsLoaded(
        upcomingBookings: currentState.upcomingBookings,
        pastBookings: currentState.pastBookings,
        activeTab: tab,
      ));
    } else if (state is BookingsEmpty) {
      emit(BookingsEmpty(tab: tab));
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    if (state is! BookingsLoaded) return;

    // Cache current state in case we need to revert
    final currentState = state as BookingsLoaded;

    // We optionally might want to emit a loading state here, but since the
    // requirement only says Right->reload/success and Left->error, we'll
    // directly call the usecase.

    final result = await _cancelBookingUseCase(CancelBookingParams(
      bookingId: bookingId,
      reason: reason,
    ));

    result.fold(
      (failure) {
        // We emit the error, then we could optionally put the loaded state back
        // but the standard flow would be to show an error dialog using a BlocListener
        emit(BookingsError(message: failure.message));
        // Restore loaded state immediately after error is emitted so the list doesn't disappear
        emit(currentState);
      },
      (_) {
        // Successfully cancelled
        emit(BookingCancelSuccess(bookingId: bookingId));
        // Reload bookings to reflect the cancelled status
        loadBookings();
      },
    );
  }

  void refresh() {
    loadBookings();
  }
}
