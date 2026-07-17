import 'package:equatable/equatable.dart';

import '../../domain/entities/search_filter.dart';

/// Base class for all search-related events.
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// User submitted a search with the given [filter].
class SearchInitiated extends SearchEvent {
  final SearchFilter filter;

  const SearchInitiated({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// A filter value changed while the user is still on the search screen.
class SearchFilterUpdated extends SearchEvent {
  final SearchFilter filter;

  const SearchFilterUpdated({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// User cleared all search filters.
class SearchCleared extends SearchEvent {
  const SearchCleared();
}

/// User selected or changed the target city.
class SearchCityChanged extends SearchEvent {
  final String city;

  const SearchCityChanged({required this.city});

  @override
  List<Object?> get props => [city];
}

/// User picked check-in and check-out dates.
class SearchDatesChanged extends SearchEvent {
  final DateTime checkIn;
  final DateTime checkOut;

  const SearchDatesChanged({
    required this.checkIn,
    required this.checkOut,
  });

  @override
  List<Object?> get props => [checkIn, checkOut];
}

/// User changed the guest count.
class SearchGuestsChanged extends SearchEvent {
  final int count;

  const SearchGuestsChanged({required this.count});

  @override
  List<Object?> get props => [count];
}

/// User changed the sort order.
class SearchSortChanged extends SearchEvent {
  final SortOrder sortOrder;

  const SearchSortChanged({required this.sortOrder});

  @override
  List<Object?> get props => [sortOrder];
}

/// User scrolled near the end — request next Explore cursor page.
class SearchLoadMoreRequested extends SearchEvent {
  const SearchLoadMoreRequested();
}
