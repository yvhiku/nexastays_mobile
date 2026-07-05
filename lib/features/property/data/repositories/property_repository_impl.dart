import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../search/domain/entities/search_filter.dart';
import '../../../search/domain/search_filter_applier.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/listing_reviews_result.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_local_datasource.dart';
import '../datasources/property_remote_datasource.dart';
import '../models/review_model.dart';
import '../../../wishlist/domain/repositories/wishlist_repository.dart';
import '../../../wishlist/data/repositories/wishlist_repository_impl.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.wishlistRepository,
    required this.wishlistRepositoryImpl,
  });

  final PropertyRemoteDataSource remoteDataSource;
  final PropertyLocalDataSource localDataSource;
  final WishlistRepository wishlistRepository;
  final WishlistRepositoryImpl wishlistRepositoryImpl;

  // ── getProperties ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Property>>> getProperties({
    SearchFilter? filter,
    bool featured = false,
    bool trending = false,
  }) async {
    try {
      final models = await remoteDataSource.getProperties(
        city: filter?.city,
        checkIn: filter?.checkIn,
        checkOut: filter?.checkOut,
        guests: filter != null && filter.guestCount > 1 ? filter.guestCount : null,
        verifiedOnly: filter?.verifiedOnly,
        instantBookOnly: filter?.instantBookOnly,
        guestType: filter?.guestType,
        vibeTags: filter?.vibes,
        minPrice: filter?.minPrice,
        maxPrice: filter?.maxPrice,
        sortOrder: filter?.sortOrder.name,
        featured: featured,
        trending: trending,
      );

      // Cache featured/trending separately for offline fallback.
      if (featured) {
        await localDataSource.cacheFeaturedProperties(models);
      }
      if (trending) {
        await localDataSource.cacheTrendingProperties(models);
      }

      var properties = models.cast<Property>();
      if (filter != null) {
        properties = applySearchFilter(properties, filter);
      }

      return Right(properties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      // Attempt cache fallback for featured / trending queries.
      try {
        if (featured) {
          final cached = await localDataSource.getCachedFeaturedProperties();
          return Right(cached.cast<Property>());
        }
        if (trending) {
          final cached = await localDataSource.getCachedTrendingProperties();
          return Right(cached.cast<Property>());
        }
      } on CacheException {
        // No cache available — fall through.
      }
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getPropertyById ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Property>> getPropertyById(String id) async {
    try {
      final model = await remoteDataSource.getPropertyById(id);
      await localDataSource.cachePropertyDetail(model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      try {
        final cached = await localDataSource.getCachedPropertyDetail(id);
        if (cached.exactAddress.isNotEmpty) {
          return Right(cached);
        }
        return const Left(
          NetworkFailure('Could not refresh listing location. Check your connection.'),
        );
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getReviews ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ListingReviewsResult>> getReviews({
    required String propertyId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getReviews(
        propertyId: propertyId,
        page: page,
        limit: limit,
      );
      final models = result.reviews;

      // Only cache the first page.
      if (page == 1) {
        await localDataSource.cacheReviews(
          propertyId,
          models.map(ReviewModel.fromEntity).toList(),
        );
      }

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      try {
        final cached = await localDataSource.getCachedReviews(propertyId);
        return Right(
          ListingReviewsResult(
            reviews: cached.cast<Review>(),
            apiTotalCount: cached.length,
          ),
        );
      } on CacheException {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getFeaturedProperties ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Property>>> getFeaturedProperties() async {
    try {
      final models = await remoteDataSource.getFeaturedProperties();
      await localDataSource.cacheFeaturedProperties(models);
      return Right(models.cast<Property>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      try {
        final cached = await localDataSource.getCachedFeaturedProperties();
        return Right(cached.cast<Property>());
      } on CacheException {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getTrendingProperties ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Property>>> getTrendingProperties() async {
    try {
      final models = await remoteDataSource.getTrendingProperties();
      await localDataSource.cacheTrendingProperties(models);
      return Right(models.cast<Property>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException {
      try {
        final cached = await localDataSource.getCachedTrendingProperties();
        return Right(cached.cast<Property>());
      } on CacheException {
        return const Left(NetworkFailure());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── getSavedProperties ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Property>>> getSavedProperties(String userId) async {
    return wishlistRepository.getSavedProperties(userId);
  }

  // ── saveProperty ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> saveProperty({
    required String userId,
    required String propertyId,
    Property? property,
  }) async {
    try {
      final result = await wishlistRepository.addToWishlist(
        userId: userId,
        propertyId: propertyId,
      );

      return await result.fold(
        (failure) async => Left(failure),
        (_) async {
          if (property != null) {
            await wishlistRepositoryImpl.cachePropertyForWishlist(
              userId,
              property,
            );
          } else {
            final fetched = await getPropertyById(propertyId);
            await fetched.fold(
              (_) async {},
              (p) => wishlistRepositoryImpl.cachePropertyForWishlist(
                userId,
                p,
              ),
            );
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // ── unsaveProperty ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> unsaveProperty({
    required String userId,
    required String propertyId,
  }) async {
    return wishlistRepository.removeFromWishlist(
      userId: userId,
      propertyId: propertyId,
    );
  }

  // ── isPropertySaved ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> isPropertySaved({
    required String userId,
    required String propertyId,
  }) async {
    return wishlistRepository.isPropertySaved(
      userId: userId,
      propertyId: propertyId,
    );
  }
}
