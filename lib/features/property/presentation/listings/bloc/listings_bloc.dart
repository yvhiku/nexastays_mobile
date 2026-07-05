import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/session/session_manager.dart';
import '../../../../search/domain/entities/search_filter.dart';
import '../../../../wishlist/domain/repositories/wishlist_repository.dart';
import '../../../domain/entities/property.dart';
import '../../../domain/repositories/property_repository.dart';
import '../../../domain/usecases/get_properties_usecase.dart';
import 'listings_event.dart';
import 'listings_state.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  final GetPropertiesUseCase getProperties;
  final PropertyRepository propertyRepository;
  final WishlistRepository wishlistRepository;
  final SessionManager sessionManager;

  ListingsBloc({
    required this.getProperties,
    required this.propertyRepository,
    required this.wishlistRepository,
    required this.sessionManager,
  }) : super(const ListingsInitial()) {
    on<ListingsLoadRequested>(_onLoadRequested);
    on<ListingsRefreshRequested>(_onRefreshRequested);
    on<ListingsLoadMoreRequested>(_onLoadMoreRequested);
    on<ListingsSortChanged>(_onSortChanged);
    on<ListingsFilterChanged>(_onFilterChanged);
    on<ListingsSaveToggled>(_onSaveToggled);
  }

  Future<Set<String>> _loadSavedIds() async {
    final userId = sessionManager.userId;
    if (userId == null) return {};

    final result = await wishlistRepository.getSavedPropertyIds(userId);
    return result.fold((_) => {}, (ids) => ids);
  }

  Future<void> _onLoadRequested(
    ListingsLoadRequested event,
    Emitter<ListingsState> emit,
  ) async {
    emit(const ListingsLoading());

    final savedIds = await _loadSavedIds();

    final failureOrProperties = await getProperties(
      GetPropertiesParams(
        filter: event.filter,
        featured: event.featured,
        trending: event.trending,
      ),
    );

    failureOrProperties.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (properties) {
        if (properties.isEmpty) {
          emit(ListingsEmpty(filter: event.filter));
        } else {
          emit(ListingsLoaded(
            properties: _sortProperties(properties, SortOrder.bestMatch),
            activeFilter: event.filter,
            totalCount: properties.length,
            hasMore: false,
            currentPage: 1,
            savedPropertyIds: savedIds,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshRequested(
    ListingsRefreshRequested event,
    Emitter<ListingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ListingsLoaded) return;

    emit(ListingsRefreshing(currentProperties: currentState.properties));

    final failureOrProperties = await getProperties(
      GetPropertiesParams(
        filter: currentState.activeFilter,
      ),
    );

    failureOrProperties.fold(
      (failure) => emit(ListingsError(
        message: failure.message,
        cachedProperties: currentState.properties,
      )),
      (properties) {
        if (properties.isEmpty) {
          emit(ListingsEmpty(filter: currentState.activeFilter));
        } else {
          emit(ListingsLoaded(
            properties: _sortProperties(properties, currentState.sortOrder),
            activeFilter: currentState.activeFilter,
            sortOrder: currentState.sortOrder,
            totalCount: properties.length,
            hasMore: false,
            currentPage: 1,
            savedPropertyIds: currentState.savedPropertyIds,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    ListingsLoadMoreRequested event,
    Emitter<ListingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ListingsLoaded || !currentState.hasMore) return;

    emit(ListingsLoadingMore(currentProperties: currentState.properties));

    // Simulate loading next page (in real app, pass page down to repo)
    final failureOrProperties = await getProperties(
      GetPropertiesParams(
        filter: currentState.activeFilter,
      ),
    );

    failureOrProperties.fold(
      (failure) => emit(ListingsError(
        message: failure.message,
        cachedProperties: currentState.properties,
      )),
      (properties) {
        final allProps = [...currentState.properties, ...properties];
        emit(ListingsLoaded(
          properties: _sortProperties(allProps, currentState.sortOrder),
          activeFilter: currentState.activeFilter,
          sortOrder: currentState.sortOrder,
          totalCount: allProps.length,
          hasMore: false, // Set to true if proper pagination exists
          currentPage: currentState.currentPage + 1,
          savedPropertyIds: currentState.savedPropertyIds,
        ));
      },
    );
  }

  void _onSortChanged(
    ListingsSortChanged event,
    Emitter<ListingsState> emit,
  ) {
    if (state is ListingsLoaded) {
      final currentState = state as ListingsLoaded;
      emit(ListingsLoaded(
        properties: _sortProperties(currentState.properties, event.sortOrder),
        activeFilter: currentState.activeFilter,
        sortOrder: event.sortOrder,
        totalCount: currentState.totalCount,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
        savedPropertyIds: currentState.savedPropertyIds,
      ));
    }
  }

  Future<void> _onFilterChanged(
    ListingsFilterChanged event,
    Emitter<ListingsState> emit,
  ) async {
    // Treat as a fresh initial load with the new filter
    emit(const ListingsLoading());

    final savedIds = await _loadSavedIds();

    final failureOrProperties = await getProperties(
      GetPropertiesParams(filter: event.filter),
    );

    failureOrProperties.fold(
      (failure) => emit(ListingsError(message: failure.message)),
      (properties) {
        if (properties.isEmpty) {
          emit(ListingsEmpty(filter: event.filter));
        } else {
          emit(ListingsLoaded(
            properties: _sortProperties(properties, SortOrder.bestMatch),
            activeFilter: event.filter,
            totalCount: properties.length,
            hasMore: false,
            currentPage: 1,
            savedPropertyIds: savedIds,
          ));
        }
      },
    );
  }

  Future<void> _onSaveToggled(
    ListingsSaveToggled event,
    Emitter<ListingsState> emit,
  ) async {
    if (state is! ListingsLoaded) return;
    final currentState = state as ListingsLoaded;

    final userId = sessionManager.userId;
    if (userId == null) return;

    final newSavedIds = Set<String>.from(currentState.savedPropertyIds);

    // Optimistic UI update
    if (event.currentlySaved) {
      newSavedIds.remove(event.propertyId);
    } else {
      newSavedIds.add(event.propertyId);
    }

    emit(ListingsLoaded(
      properties: currentState.properties,
      activeFilter: currentState.activeFilter,
      sortOrder: currentState.sortOrder,
      totalCount: currentState.totalCount,
      hasMore: currentState.hasMore,
      currentPage: currentState.currentPage,
      savedPropertyIds: newSavedIds,
    ));

    // Call repo and revert if failed
    final result = event.currentlySaved
        ? await propertyRepository.unsaveProperty(
            userId: userId, propertyId: event.propertyId)
        : await propertyRepository.saveProperty(
            userId: userId,
            propertyId: event.propertyId,
            property: event.property,
          );

    result.fold(
      (failure) {
        // Revert UI update
        final revertedIds = Set<String>.from(currentState.savedPropertyIds);
        emit(ListingsLoaded(
          properties: currentState.properties,
          activeFilter: currentState.activeFilter,
          sortOrder: currentState.sortOrder,
          totalCount: currentState.totalCount,
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
          savedPropertyIds: revertedIds,
        ));
      },
      (_) {}, // Success, optimistic update stands
    );
  }

  List<Property> _sortProperties(List<Property> properties, SortOrder order) {
    final list = List<Property>.from(properties);
    switch (order) {
      case SortOrder.bestMatch:
        // No-op or some complex scoring logic
        break;
      case SortOrder.priceLow:
        list.sort((a, b) => a.nightlyRate.compareTo(b.nightlyRate));
        break;
      case SortOrder.priceHigh:
        list.sort((a, b) => b.nightlyRate.compareTo(a.nightlyRate));
        break;
      case SortOrder.newest:
        // Optional: Assuming newer properties at end, or implement timestamp logic
        break;
    }
    return list;
  }
}
