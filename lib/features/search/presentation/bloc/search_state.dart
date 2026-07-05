import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/property.dart';
import '../../domain/entities/search_filter.dart';

/// Base class for all search-related states.
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Default state before any search action.
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Emitted while a search request is in flight.
class SearchLoading extends SearchState {
  final SearchFilter filter;

  const SearchLoading({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Emitted when search results are returned successfully.
class SearchResults extends SearchState {
  final List<Property> properties;
  final SearchFilter activeFilter;
  final int totalCount;
  final SortOrder sortOrder;

  const SearchResults({
    required this.properties,
    required this.activeFilter,
    required this.totalCount,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [properties, activeFilter, totalCount, sortOrder];
}

/// Emitted when a search returns zero results.
class SearchEmpty extends SearchState {
  final SearchFilter filter;

  const SearchEmpty({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Emitted when a search request fails.
class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
