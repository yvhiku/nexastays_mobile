import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/session/session_manager.dart';
import '../../../property/data/datasources/property_remote_datasource.dart';
import '../../../property/data/models/property_model.dart';
import '../../../property/domain/entities/property.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_datasource.dart';

// =============================================================================
// Wishlist Repository Implementation (Local-only / Offline-first)
// =============================================================================

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({
    required this.localDataSource,
    required this.sessionManager,
    this.propertyRemoteDataSource,
  });

  final WishlistLocalDataSource localDataSource;
  final SessionManager sessionManager;
  final PropertyRemoteDataSource? propertyRemoteDataSource;

  // ── WishlistRepository contract ──────────────────────────────────────

  @override
  Future<Either<Failure, List<Property>>> getSavedProperties(
    String userId,
  ) async {
    try {
      final ids = await localDataSource.getSavedIds(userId);
      if (ids.isEmpty) return const Right([]);

      final cached = await localDataSource.getCachedProperties(userId);
      final cachedById = {for (final p in cached) p.id: p};
      final missingIds = ids.where((id) => !cachedById.containsKey(id)).toList();

      if (missingIds.isNotEmpty && propertyRemoteDataSource != null) {
        for (final id in missingIds) {
          try {
            final model = await propertyRemoteDataSource!.getPropertyById(id);
            await localDataSource.cacheProperty(userId, model);
            cachedById[id] = model;
          } catch (_) {
            // Skip listings that no longer exist or are unreachable.
          }
        }
      }

      final properties = ids
          .map((id) => cachedById[id])
          .whereType<PropertyModel>()
          .cast<Property>()
          .toList();

      return Right(properties);
    } on CacheException {
      return const Right([]);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist({
    required String userId,
    required String propertyId,
  }) async {
    try {
      await localDataSource.saveId(userId, propertyId);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to save'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist({
    required String userId,
    required String propertyId,
  }) async {
    try {
      await localDataSource.removeId(userId, propertyId);
      await localDataSource.removeCachedProperty(userId, propertyId);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Failed to remove'));
    }
  }

  @override
  Future<Either<Failure, bool>> isPropertySaved({
    required String userId,
    required String propertyId,
  }) async {
    try {
      final result = await localDataSource.isSaved(userId, propertyId);
      return Right(result);
    } on CacheException {
      // Graceful fallback — assume not saved.
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getSavedPropertyIds(
    String userId,
  ) async {
    try {
      final ids = await localDataSource.getSavedIds(userId);
      return Right(ids);
    } on CacheException {
      return const Right({});
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────

  /// Caches a full [Property] locally so the wishlist page can display
  /// property details offline.
  ///
  /// Called from ListingsBloc / PropertyDetailCubit when the user saves.
  Future<void> cachePropertyForWishlist(
    String userId,
    Property property,
  ) async {
    await localDataSource.cacheProperty(
      userId,
      PropertyModel.fromEntity(property),
    );
  }
}
