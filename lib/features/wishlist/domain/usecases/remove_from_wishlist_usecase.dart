import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wishlist_repository.dart';
import 'add_to_wishlist_usecase.dart';

// =============================================================================
// Remove From Wishlist Use Case
// =============================================================================

/// Removes a property from the user's local wishlist.
///
/// Validates that [WishlistParams.userId] and [WishlistParams.propertyId]
/// are non-empty before delegating to [WishlistRepository.removeFromWishlist].
class RemoveFromWishlistUseCase extends UseCase<void, WishlistParams> {
  RemoveFromWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Either<Failure, void>> call(WishlistParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User not authenticated'));
    }
    if (params.propertyId.isEmpty) {
      return const Left(ValidationFailure('Invalid property'));
    }

    return _repository.removeFromWishlist(
      userId: params.userId,
      propertyId: params.propertyId,
    );
  }
}
