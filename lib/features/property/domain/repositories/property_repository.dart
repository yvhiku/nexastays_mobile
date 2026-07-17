import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../search/domain/entities/search_filter.dart';
import '../entities/property.dart';
import '../entities/listing_reviews_result.dart';

class ExploreSearchPage {
  const ExploreSearchPage({
    required this.properties,
    required this.hasMore,
    this.nextCursor,
  });

  final List<Property> properties;
  final bool hasMore;
  final String? nextCursor;
}

abstract class PropertyRepository {
  Future<Either<Failure, List<Property>>> getProperties({
    SearchFilter? filter,
    bool featured = false,
    bool trending = false,
  });

  Future<Either<Failure, ExploreSearchPage>> exploreSearch({
    SearchFilter? filter,
    String? cursor,
    int limit = 24,
  });

  Future<Either<Failure, List<Property>>> exploreMap({
    required double north,
    required double south,
    required double east,
    required double west,
    SearchFilter? filter,
  });

  Future<Either<Failure, Property>> getPropertyById(String id);

  Future<Either<Failure, ListingReviewsResult>> getReviews({
    required String propertyId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, List<Property>>> getFeaturedProperties();

  Future<Either<Failure, List<Property>>> getTrendingProperties();

  Future<Either<Failure, List<Property>>> getSavedProperties(String userId);

  Future<Either<Failure, void>> saveProperty({
    required String userId,
    required String propertyId,
    Property? property,
  });

  Future<Either<Failure, void>> unsaveProperty({
    required String userId,
    required String propertyId,
  });

  Future<Either<Failure, bool>> isPropertySaved({
    required String userId,
    required String propertyId,
  });
}
