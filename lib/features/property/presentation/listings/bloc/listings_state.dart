import 'package:equatable/equatable.dart';

import '../../../../search/domain/entities/search_filter.dart';
import '../../../domain/entities/property.dart';

sealed class ListingsState extends Equatable {
  const ListingsState();

  @override
  List<Object?> get props => [];
}

class ListingsInitial extends ListingsState {
  const ListingsInitial();
}

class ListingsLoading extends ListingsState {
  const ListingsLoading();
}

class ListingsRefreshing extends ListingsState {
  final List<Property> currentProperties;

  const ListingsRefreshing({required this.currentProperties});

  @override
  List<Object?> get props => [currentProperties];
}

class ListingsLoaded extends ListingsState {
  final List<Property> properties;
  final SearchFilter? activeFilter;
  final SortOrder sortOrder;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final Set<String> savedPropertyIds;

  const ListingsLoaded({
    required this.properties,
    this.activeFilter,
    this.sortOrder = SortOrder.bestMatch,
    required this.totalCount,
    required this.hasMore,
    required this.currentPage,
    this.savedPropertyIds = const {},
  });

  @override
  List<Object?> get props => [
        properties,
        activeFilter,
        sortOrder,
        totalCount,
        hasMore,
        currentPage,
        savedPropertyIds,
      ];
}

class ListingsLoadingMore extends ListingsState {
  final List<Property> currentProperties;

  const ListingsLoadingMore({required this.currentProperties});

  @override
  List<Object?> get props => [currentProperties];
}

class ListingsEmpty extends ListingsState {
  final SearchFilter? filter;

  const ListingsEmpty({this.filter});

  @override
  List<Object?> get props => [filter];
}

class ListingsError extends ListingsState {
  final String message;
  final List<Property> cachedProperties;

  const ListingsError({
    required this.message,
    this.cachedProperties = const [],
  });

  @override
  List<Object?> get props => [message, cachedProperties];
}
