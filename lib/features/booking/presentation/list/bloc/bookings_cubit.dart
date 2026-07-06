import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/session/session_manager.dart';
import '../../../../../core/utils/booking_lifecycle.dart';
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
        if (bookings.isEmpty) {
          emit(const BookingsEmpty());
        } else {
          final previous = state is BookingsLoaded ? state as BookingsLoaded : null;
          emit(BookingsLoaded(
            allBookings: bookings,
            activeTab: previous?.activeTab ?? BookingsTab.upcoming,
            filters: previous?.filters ?? BookingFilters.defaults,
          ));
        }
      },
    );
  }

  void switchTab(BookingsTab tab) {
    if (state is BookingsLoaded) {
      final current = state as BookingsLoaded;
      if (current.activeTab == tab) return;
      emit(current.copyWith(activeTab: tab, visibleCount: bookingsPageSize));
    }
  }

  void setSearch(String query) {
    if (state is! BookingsLoaded) return;
    final current = state as BookingsLoaded;
    emit(current.copyWith(
      filters: current.filters.copyWith(search: query),
      visibleCount: bookingsPageSize,
    ));
  }

  void applyFilters(BookingFilters filters) {
    if (state is! BookingsLoaded) return;
    final current = state as BookingsLoaded;
    emit(current.copyWith(filters: filters, visibleCount: bookingsPageSize));
  }

  void clearFilters() {
    if (state is! BookingsLoaded) return;
    final current = state as BookingsLoaded;
    emit(current.copyWith(
      filters: BookingFilters.defaults.copyWith(search: current.filters.search),
      visibleCount: bookingsPageSize,
    ));
  }

  void loadMore() {
    if (state is! BookingsLoaded) return;
    final current = state as BookingsLoaded;
    if (!current.hasMore) return;
    emit(current.copyWith(
      visibleCount: current.visibleCount + bookingsPageSize,
    ));
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    if (state is! BookingsLoaded) return;

    final currentState = state as BookingsLoaded;

    final result = await _cancelBookingUseCase(CancelBookingParams(
      bookingId: bookingId,
      reason: reason,
    ));

    result.fold(
      (failure) {
        emit(BookingsError(message: failure.message));
        emit(currentState);
      },
      (_) {
        emit(BookingCancelSuccess(bookingId: bookingId));
        loadBookings();
      },
    );
  }

  void refresh() => loadBookings();
}
