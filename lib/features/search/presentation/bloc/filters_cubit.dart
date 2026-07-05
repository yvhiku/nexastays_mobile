import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/search_filter.dart';

/// Cubit managing the ephemeral filter form state on the filters
/// bottom sheet, separate from the committed [SearchBloc] state.
///
/// Each setter emits a new [SearchFilter] via `copyWith`. The caller
/// is responsible for reading the final [state] and dispatching a
/// `SearchFilterUpdated` event to the [SearchBloc] when the user
/// taps "Apply".
class FiltersCubit extends Cubit<SearchFilter> {
  FiltersCubit() : super(const SearchFilter());

  /// Optionally seed the cubit with an existing filter
  /// (e.g. when re-opening the sheet with previous selections).
  FiltersCubit.from(SearchFilter initial) : super(initial);

  // ── Setters ─────────────────────────────────────────────────────────────

  void setCity(String city) {
    emit(state.copyWith(city: city));
  }

  void setDates(DateTime checkIn, DateTime checkOut) {
    emit(state.copyWith(checkIn: checkIn, checkOut: checkOut));
  }

  void setGuests(int count) {
    emit(state.copyWith(guestCount: count));
  }

  void toggleVerifiedOnly() {
    emit(state.copyWith(verifiedOnly: !state.verifiedOnly));
  }

  void toggleInstantOnly() {
    emit(state.copyWith(instantBookOnly: !state.instantBookOnly));
  }

  /// Adds [tag] if not present, removes it if already selected.
  void toggleVibe(String tag) {
    final updated = List<String>.from(state.vibes);
    if (updated.contains(tag)) {
      updated.remove(tag);
    } else {
      updated.add(tag);
    }
    emit(state.copyWith(vibes: updated));
  }

  void setGuestType(String? type) {
    emit(state.copyWith(guestType: type));
  }

  void setPriceRange(double min, double max) {
    emit(state.copyWith(minPrice: min, maxPrice: max));
  }

  void setMinBeds(int beds) {
    emit(state.copyWith(minBeds: beds));
  }

  void setSortOrder(SortOrder order) {
    emit(state.copyWith(sortOrder: order));
  }

  /// Resets all filters back to defaults.
  void resetFilters() {
    emit(const SearchFilter());
  }

  /// No-op convenience — the caller should read [state] and dispatch
  /// `SearchFilterUpdated(filter: state)` to the [SearchBloc].
  ///
  /// Exists so the bottom sheet can call `filtersCubit.applyFilters()`
  /// as a semantic intent without knowing about SearchBloc internals.
  void applyFilters() {
    // State is already up-to-date; the caller reads it.
  }
}
