import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/session_manager.dart';
import '../../../property/domain/entities/property.dart';
import '../../../search/domain/entities/search_filter.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';
import 'wishlist_state.dart';

// =============================================================================
// Wishlist Cubit
// =============================================================================

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({
    required this.addToWishlistUseCase,
    required this.removeFromWishlistUseCase,
    required this.wishlistRepository,
    required this.sessionManager,
  }) : super(const WishlistInitial());

  final AddToWishlistUseCase addToWishlistUseCase;
  final RemoveFromWishlistUseCase removeFromWishlistUseCase;
  final WishlistRepositoryImpl wishlistRepository;
  final SessionManager sessionManager;

  // ── Load ──────────────────────────────────────────────────────────────

  Future<void> loadWishlist() async {
    emit(const WishlistLoading());

    final userId = sessionManager.userId;
    if (userId == null) {
      emit(const WishlistError(
        message: 'Please sign in to view saved properties',
      ));
      return;
    }

    final result = await wishlistRepository.getSavedProperties(userId);

    result.fold(
      (failure) => emit(WishlistError(message: failure.message)),
      (properties) {
        if (properties.isEmpty) {
          emit(const WishlistEmpty());
        } else {
          final ids = properties.map((p) => p.id).toSet();
          emit(WishlistLoaded(
            savedProperties: properties,
            savedIds: ids,
            sortOrder: SortOrder.newest,
          ));
        }
      },
    );
  }

  // ── Add ───────────────────────────────────────────────────────────────

  Future<void> addProperty(Property property) async {
    final currentState = state;
    if (currentState is! WishlistLoaded && currentState is! WishlistEmpty) {
      return;
    }

    final userId = sessionManager.userId!;

    // Gather current list (empty if WishlistEmpty).
    final currentProperties = currentState is WishlistLoaded
        ? currentState.savedProperties
        : <Property>[];

    // Optimistic UI — show saving indicator.
    emit(WishlistPropertySaving(
      propertyId: property.id,
      currentProperties: currentProperties,
    ));

    final result = await addToWishlistUseCase(WishlistParams(
      userId: userId,
      propertyId: property.id,
    ));

    // Cache full property for offline display.
    await wishlistRepository.cachePropertyForWishlist(userId, property);

    result.fold(
      (failure) {
        // Revert to previous state.
        if (currentProperties.isEmpty) {
          emit(const WishlistEmpty());
        } else {
          emit(WishlistLoaded(
            savedProperties: currentProperties,
            savedIds: currentProperties.map((p) => p.id).toSet(),
            sortOrder: SortOrder.newest,
          ));
        }
        emit(WishlistError(message: failure.message));
      },
      (_) {
        final newList = [...currentProperties, property];
        emit(WishlistLoaded(
          savedProperties: newList,
          savedIds: newList.map((p) => p.id).toSet(),
          sortOrder: SortOrder.newest,
        ));
      },
    );
  }

  // ── Remove ────────────────────────────────────────────────────────────

  Future<void> removeProperty(String propertyId) async {
    final currentState = state;
    if (currentState is! WishlistLoaded) return;

    final userId = sessionManager.userId!;
    final previousProperties = currentState.savedProperties;

    // Optimistic remove.
    final updatedList =
        previousProperties.where((p) => p.id != propertyId).toList();

    emit(WishlistPropertyRemoved(
      propertyId: propertyId,
      updatedProperties: updatedList,
    ));

    if (updatedList.isEmpty) {
      emit(const WishlistEmpty());
    } else {
      emit(WishlistLoaded(
        savedProperties: updatedList,
        savedIds: updatedList.map((p) => p.id).toSet(),
        sortOrder: currentState.sortOrder,
      ));
    }

    final result = await removeFromWishlistUseCase(WishlistParams(
      userId: userId,
      propertyId: propertyId,
    ));

    result.fold(
      (failure) {
        // Revert to previous state.
        emit(WishlistLoaded(
          savedProperties: previousProperties,
          savedIds: previousProperties.map((p) => p.id).toSet(),
          sortOrder: currentState.sortOrder,
        ));
        emit(WishlistError(message: failure.message));
      },
      (_) {
        // Already updated optimistically — nothing more to do.
      },
    );
  }

  // ── Undo remove ───────────────────────────────────────────────────────

  /// Re-adds a property that was just removed (called from SnackBar undo).
  void undoRemove(Property property) => addProperty(property);

  // ── Sort ──────────────────────────────────────────────────────────────

  void sortWishlist(SortOrder order) {
    final currentState = state;
    if (currentState is! WishlistLoaded) return;

    final sorted = List<Property>.from(currentState.savedProperties);

    switch (order) {
      case SortOrder.priceLow:
        sorted.sort((a, b) => a.nightlyRate.compareTo(b.nightlyRate));
      case SortOrder.priceHigh:
        sorted.sort((a, b) => b.nightlyRate.compareTo(a.nightlyRate));
      case SortOrder.newest:
        sorted.sort((a, b) => b.listedAt.compareTo(a.listedAt));
      case SortOrder.bestMatch:
        // No-op — keep original order.
        break;
    }

    emit(currentState.copyWith(
      savedProperties: sorted,
      sortOrder: order,
    ));
  }

  // ── Quick lookup ──────────────────────────────────────────────────────

  /// O(1) check used by property cards across the app.
  bool isPropertySaved(String propertyId) {
    final currentState = state;
    if (currentState is WishlistLoaded) {
      return currentState.savedIds.contains(propertyId);
    }
    return false;
  }
}
