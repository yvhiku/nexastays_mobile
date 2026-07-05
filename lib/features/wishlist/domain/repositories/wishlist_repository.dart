import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../property/domain/entities/property.dart';

/// Abstract repository for wishlist operations.
///
/// Wishlist is LOCAL only (offline-first) — no backend endpoint.
/// Data persists on device via LocalStorage.
///
/// [getSavedPropertyIds] is called on app start and cached in memory
/// for O(1) lookup in property cards across the app (used by
/// ListingsBloc, PropertyDetailCubit).
abstract class WishlistRepository {
  /// Returns the full [Property] objects the user has saved.
  Future<Either<Failure, List<Property>>> getSavedProperties(
    String userId,
  );

  /// Adds a property to the user's wishlist.
  Future<Either<Failure, void>> addToWishlist({
    required String userId,
    required String propertyId,
  });

  /// Removes a property from the user's wishlist.
  Future<Either<Failure, void>> removeFromWishlist({
    required String userId,
    required String propertyId,
  });

  /// Checks whether a single property is saved.
  Future<Either<Failure, bool>> isPropertySaved({
    required String userId,
    required String propertyId,
  });

  /// Returns just the IDs of saved properties for fast lookup across the app.
  ///
  /// Called on app start and cached in memory for O(1) lookup
  /// in property cards (ListingsBloc, PropertyDetailCubit).
  Future<Either<Failure, Set<String>>> getSavedPropertyIds(
    String userId,
  );
}
