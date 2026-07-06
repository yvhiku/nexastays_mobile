import 'package:equatable/equatable.dart';

import '../../../../../core/utils/booking_lifecycle.dart';
import '../../../domain/entities/booking.dart';

sealed class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object?> get props => [];
}

class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

class BookingsLoaded extends BookingsState {
  final List<Booking> allBookings;
  final BookingsTab activeTab;
  final BookingFilters filters;
  final int visibleCount;

  const BookingsLoaded({
    required this.allBookings,
    required this.activeTab,
    required this.filters,
    this.visibleCount = bookingsPageSize,
  });

  List<Booking> get filteredBookings =>
      filterAndSortBookings(allBookings, activeTab, filters);

  List<Booking> get visibleBookings =>
      filteredBookings.take(visibleCount).toList();

  bool get hasMore => visibleCount < filteredBookings.length;

  Map<BookingsTab, int> get tabCounts => countByTab(allBookings);

  List<String> get cities => uniqueCities(allBookings);

  BookingsLoaded copyWith({
    List<Booking>? allBookings,
    BookingsTab? activeTab,
    BookingFilters? filters,
    int? visibleCount,
  }) {
    return BookingsLoaded(
      allBookings: allBookings ?? this.allBookings,
      activeTab: activeTab ?? this.activeTab,
      filters: filters ?? this.filters,
      visibleCount: visibleCount ?? this.visibleCount,
    );
  }

  @override
  List<Object?> get props => [allBookings, activeTab, filters, visibleCount];
}

class BookingsEmpty extends BookingsState {
  const BookingsEmpty();
}

class BookingsError extends BookingsState {
  final String message;

  const BookingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookingCancelSuccess extends BookingsState {
  final String bookingId;

  const BookingCancelSuccess({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}
