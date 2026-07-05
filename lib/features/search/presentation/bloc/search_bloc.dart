import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC that drives the search feature.
///
/// Handles search initiation, filter updates (debounced 300 ms),
/// clearing, and client-side sort changes.
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
  }

  // ── Event handlers ──────────────────────────────────────────────────────

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
        break; // keep original API order
    }

    emit(SearchResults(
      properties: sorted,
      activeFilter: current.activeFilter,
      totalCount: current.totalCount,
      sortOrder: event.sortOrder,
    ));
  }

  // ── Shared search logic ─────────────────────────────────────────────────

  Future<void> _performSearch(
    SearchFilter filter,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(filter: filter));

    try {
      final result = await _searchUseCase(filter);

      result.fold(
        (failure) => emit(SearchError(message: failure.message)),
        (properties) {
          if (properties.isEmpty) {
            emit(SearchEmpty(filter: filter));
          } else {
            emit(SearchResults(
              properties: properties,
              activeFilter: filter,
              totalCount: properties.length,
              sortOrder: filter.sortOrder,
            ));
          }
        },
      );
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  // ── Debounce transformer ────────────────────────────────────────────────

  /// Returns an [EventTransformer] that debounces events by [duration].
  ///
  /// Uses `Stream.asyncExpand` to cancel in-flight processing when a new
  /// event arrives within the window — no extra package required.
  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) {
      return events
          .transform(_DebounceStreamTransformer<T>(duration))
          .asyncExpand(mapper);
    };
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Lightweight debounce stream transformer
// ═════════════════════════════════════════════════════════════════════════════

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
