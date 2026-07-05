import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wishlist_repository.dart';

// =============================================================================
// Add To Wishlist Use Case
// =============================================================================

/// Adds a property to the user's local wishlist.
///
/// Validates that [WishlistParams.userId] and [WishlistParams.propertyId]
/// are non-empty before delegating to [WishlistRepository.addToWishlist].
class AddToWishlistUseCase extends UseCase<void, WishlistParams> {
  AddToWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Either<Failure, void>> call(WishlistParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User not authenticated'));
    }
    if (params.propertyId.isEmpty) {
      return const Left(ValidationFailure('Invalid property'));
    }

    return _repository.addToWishlist(
      userId: params.userId,
      propertyId: params.propertyId,
    );
  }
}

// =============================================================================
// Shared Params (reused by AddToWishlistUseCase & RemoveFromWishlistUseCase)
// =============================================================================

/// Parameters shared by [AddToWishlistUseCase] and the remove counterpart.
class WishlistParams extends Equatable {
  const WishlistParams({
    required this.userId,
    required this.propertyId,
  });

  final String userId;
  final String propertyId;

  @override
  List<Object?> get props => [userId, propertyId];
}
