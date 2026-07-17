import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC that drives the search feature.
///
/// Handles search initiation, filter updates (debounced 300 ms),
/// clearing, load-more cursor pages, and client-side sort changes.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchPropertiesUseCase _searchUseCase;

  /// Tracks the latest filter so incremental changes
  /// (city, dates, guests) can be merged in.
  SearchFilter _currentFilter;

  SearchBloc({
    required SearchPropertiesUseCase searchUseCase,
  })  : _searchUseCase = searchUseCase,
        _currentFilter = const SearchFilter(),
        super(const SearchInitial()) {
    on<SearchInitiated>(_onSearchInitiated);
    on<SearchFilterUpdated>(
      _onSearchFilterUpdated,
      transformer: _debounce(const Duration(milliseconds: 300)),
    );
    on<SearchCleared>(_onSearchCleared);
    on<SearchCityChanged>(_onCityChanged);
    on<SearchDatesChanged>(_onDatesChanged);
    on<SearchGuestsChanged>(_onGuestsChanged);
    on<SearchSortChanged>(_onSortChanged);
    on<SearchLoadMoreRequested>(_onLoadMore);
  }

  Future<void> _onSearchInitiated(
    SearchInitiated event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilter = event.filter;
    await _performSearch(event.filter, emit);
  }

  Future<void> _onSearchFilterUpdated(
    SearchFilterUpdated event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilter = event.filter;
    await _performSearch(event.filter, emit);
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    _currentFilter = const SearchFilter();
    add(const SearchInitiated(filter: SearchFilter()));
  }

  void _onCityChanged(
    SearchCityChanged event,
    Emitter<SearchState> emit,
  ) {
    _currentFilter = _currentFilter.copyWith(city: event.city);
    add(SearchFilterUpdated(filter: _currentFilter));
  }

  void _onDatesChanged(
    SearchDatesChanged event,
    Emitter<SearchState> emit,
  ) {
    _currentFilter = _currentFilter.copyWith(
      checkIn: event.checkIn,
      checkOut: event.checkOut,
    );
    add(SearchFilterUpdated(filter: _currentFilter));
  }

  void _onGuestsChanged(
    SearchGuestsChanged event,
    Emitter<SearchState> emit,
  ) {
    _currentFilter = _currentFilter.copyWith(guestCount: event.count);
    add(SearchFilterUpdated(filter: _currentFilter));
  }

  void _onSortChanged(
    SearchSortChanged event,
    Emitter<SearchState> emit,
  ) {
    final current = state;
    if (current is! SearchResults) return;

    final sorted = List.of(current.properties);
    switch (event.sortOrder) {
      case SortOrder.priceLow:
        sorted.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
      case SortOrder.priceHigh:
        sorted.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
      case SortOrder.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOrder.bestMatch:
        break;
    }

    emit(SearchResults(
      properties: sorted,
      activeFilter: current.activeFilter,
      totalCount: current.totalCount,
      sortOrder: event.sortOrder,
      hasMore: current.hasMore,
      nextCursor: current.nextCursor,
    ));
  }

  Future<void> _onLoadMore(
    SearchLoadMoreRequested event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchResults ||
        !current.hasMore ||
        current.nextCursor == null ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    try {
      final result = await _searchUseCase(SearchPropertiesParams(
        filter: current.activeFilter,
        cursor: current.nextCursor,
      ));

      result.fold(
        (failure) => emit(current.copyWith(isLoadingMore: false)),
        (page) {
          final seen = current.properties.map((p) => p.id).toSet();
          final appended = page.properties
              .where((p) => !seen.contains(p.id))
              .toList();
          final merged = [...current.properties, ...appended];
          emit(SearchResults(
            properties: merged,
            activeFilter: current.activeFilter,
            totalCount: merged.length,
            sortOrder: current.sortOrder,
            hasMore: page.hasMore,
            nextCursor: page.nextCursor,
            isLoadingMore: false,
          ));
        },
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _performSearch(
    SearchFilter filter,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(filter: filter));

    try {
      final result = await _searchUseCase(
        SearchPropertiesParams(filter: filter),
      );

      result.fold(
        (failure) => emit(SearchError(message: failure.message)),
        (page) {
          if (page.properties.isEmpty) {
            emit(SearchEmpty(filter: filter));
          } else {
            emit(SearchResults(
              properties: page.properties,
              activeFilter: filter,
              totalCount: page.properties.length,
              sortOrder: filter.sortOrder,
              hasMore: page.hasMore,
              nextCursor: page.nextCursor,
            ));
          }
        },
      );
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) {
      return events
          .transform(_DebounceStreamTransformer<T>(duration))
          .asyncExpand(mapper);
    };
  }
}

class _DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;

  const _DebounceStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    return Stream<T>.eventTransformed(
      stream,
      (sink) => _DebounceSink<T>(sink, duration),
    );
  }
}

class _DebounceSink<T> implements EventSink<T> {
  final EventSink<T> _outputSink;
  final Duration _duration;
  Timer? _timer;

  _DebounceSink(this._outputSink, this._duration);

  @override
  void add(T event) {
    _timer?.cancel();
    _timer = Timer(_duration, () => _outputSink.add(event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _outputSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _timer?.cancel();
    _outputSink.close();
  }
}
