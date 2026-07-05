import 'package:equatable/equatable.dart';

import '../../../../search/domain/entities/search_filter.dart';
import '../../../domain/entities/property.dart';

sealed class ListingsEvent extends Equatable {
  const ListingsEvent();

  @override
  List<Object?> get props => [];
}

class ListingsLoadRequested extends ListingsEvent {
  final SearchFilter? filter;
  final bool featured;
  final bool trending;

  const ListingsLoadRequested({
    this.filter,
    this.featured = false,
    this.trending = false,
  });

  @override
  List<Object?> get props => [filter, featured, trending];
}

class ListingsRefreshRequested extends ListingsEvent {
  const ListingsRefreshRequested();
}

class ListingsLoadMoreRequested extends ListingsEvent {
  const ListingsLoadMoreRequested();
}

class ListingsSortChanged extends ListingsEvent {
  final SortOrder sortOrder;

  const ListingsSortChanged({required this.sortOrder});

  @override
  List<Object?> get props => [sortOrder];
}

class ListingsFilterChanged extends ListingsEvent {
  final SearchFilter filter;

  const ListingsFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class ListingsSaveToggled extends ListingsEvent {
  final String propertyId;
  final bool currentlySaved;
  final Property property;

  const ListingsSaveToggled({
    required this.propertyId,
    required this.currentlySaved,
    required this.property,
  });

  @override
  List<Object?> get props => [propertyId, currentlySaved, property];
}
