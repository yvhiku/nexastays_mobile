import 'package:equatable/equatable.dart';

import '../../../property/domain/entities/property.dart';
import '../../../search/domain/entities/search_filter.dart';

// =============================================================================
// Wishlist States
// =============================================================================

/// Base state for the wishlist feature.
sealed class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data has been loaded yet.
final class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

/// Loading saved properties from local storage.
final class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

/// Successfully loaded saved properties.
final class WishlistLoaded extends WishlistState {
  const WishlistLoaded({
    required this.savedProperties,
    required this.savedIds,
    this.sortOrder = SortOrder.bestMatch,
  });

  /// Full property objects for display on the wishlist page.
  final List<Property> savedProperties;

  /// Property IDs for O(1) lookup in UI (property cards, detail page).
  final Set<String> savedIds;

  /// Current sort order applied to the list.
  final SortOrder sortOrder;

  WishlistLoaded copyWith({
    List<Property>? savedProperties,
    Set<String>? savedIds,
    SortOrder? sortOrder,
  }) {
    return WishlistLoaded(
      savedProperties: savedProperties ?? this.savedProperties,
      savedIds: savedIds ?? this.savedIds,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [savedProperties, savedIds, sortOrder];
}

/// The user has no saved properties.
final class WishlistEmpty extends WishlistState {
  const WishlistEmpty();
}

/// An error occurred while loading or modifying the wishlist.
final class WishlistError extends WishlistState {
  const WishlistError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Optimistic UI — a property is being saved; show existing list while saving.
final class WishlistPropertySaving extends WishlistState {
  const WishlistPropertySaving({
    required this.propertyId,
    required this.currentProperties,
  });

  final String propertyId;
  final List<Property> currentProperties;

  @override
  List<Object?> get props => [propertyId, currentProperties];
}

/// A property was removed — used to show a SnackBar with Undo option.
final class WishlistPropertyRemoved extends WishlistState {
  const WishlistPropertyRemoved({
    required this.propertyId,
    required this.updatedProperties,
  });

  final String propertyId;
  final List<Property> updatedProperties;

  @override
  List<Object?> get props => [propertyId, updatedProperties];
}
