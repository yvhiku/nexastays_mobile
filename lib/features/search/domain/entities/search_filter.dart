import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Sort options for property search results.
enum SortOrder { bestMatch, priceLow, priceHigh, newest }

/// Immutable filter object that describes a property search query.
///
/// Used by the search feature to build API requests and by the UI
/// to render active filter chips, summary text, etc.
class SearchFilter extends Equatable {
  static const _unset = Object();

  final String? city;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guestCount;
  final bool verifiedOnly;
  final bool instantBookOnly;
  final List<String> vibes;
  final String? guestType;
  final double? minPrice;
  final double? maxPrice;
  final int? minBeds;
  final SortOrder sortOrder;

  const SearchFilter({
    this.city,
    this.checkIn,
    this.checkOut,
    this.guestCount = 1,
    this.verifiedOnly = false,
    this.instantBookOnly = false,
    this.vibes = const [],
    this.guestType,
    this.minPrice,
    this.maxPrice,
    this.minBeds,
    this.sortOrder = SortOrder.bestMatch,
  });

  // ── Getters ─────────────────────────────────────────────────────────────

  /// `true` when any filter beyond the defaults is active.
  bool get hasActiveFilters =>
      (city != null && city!.isNotEmpty) ||
      checkIn != null ||
      checkOut != null ||
      guestCount > 1 ||
      verifiedOnly ||
      instantBookOnly ||
      vibes.isNotEmpty ||
      guestType != null ||
      minPrice != null ||
      maxPrice != null ||
      minBeds != null;

  /// Human-readable summary, e.g. "Marrakech · Jul 12–15 · 2 guests".
  String get searchSummary {
    final parts = <String>[];

    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }

    if (checkIn != null && checkOut != null) {
      final inFmt = DateFormat('MMM d');
      final outFmt = checkIn!.month == checkOut!.month
          ? DateFormat('d')
          : DateFormat('MMM d');
      parts.add('${inFmt.format(checkIn!)}–${outFmt.format(checkOut!)}');
    } else if (checkIn != null) {
      parts.add(DateFormat('MMM d').format(checkIn!));
    }

    if (guestCount > 0) {
      parts.add('$guestCount guest${guestCount == 1 ? '' : 's'}');
    }

    return parts.join(' · ');
  }

  // ── copyWith ────────────────────────────────────────────────────────────

  SearchFilter copyWith({
    Object? city = _unset,
    Object? checkIn = _unset,
    Object? checkOut = _unset,
    int? guestCount,
    bool? verifiedOnly,
    bool? instantBookOnly,
    List<String>? vibes,
    Object? guestType = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    Object? minBeds = _unset,
    SortOrder? sortOrder,
  }) {
    return SearchFilter(
      city: city == _unset ? this.city : city as String?,
      checkIn: checkIn == _unset ? this.checkIn : checkIn as DateTime?,
      checkOut: checkOut == _unset ? this.checkOut : checkOut as DateTime?,
      guestCount: guestCount ?? this.guestCount,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      instantBookOnly: instantBookOnly ?? this.instantBookOnly,
      vibes: vibes ?? this.vibes,
      guestType:
          guestType == _unset ? this.guestType : guestType as String?,
      minPrice: minPrice == _unset ? this.minPrice : minPrice as double?,
      maxPrice: maxPrice == _unset ? this.maxPrice : maxPrice as double?,
      minBeds: minBeds == _unset ? this.minBeds : minBeds as int?,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  // ── Equatable ───────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        city,
        checkIn,
        checkOut,
        guestCount,
        verifiedOnly,
        instantBookOnly,
        vibes,
        guestType,
        minPrice,
        maxPrice,
        minBeds,
        sortOrder,
      ];
}
