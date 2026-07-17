import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../search/domain/entities/search_filter.dart';
import '../entities/property.dart';

class ExploreSearchResult {
  const ExploreSearchResult({
    required this.properties,
    required this.hasMore,
    this.nextCursor,
  });

  final List<Property> properties;
  final bool hasMore;
  final String? nextCursor;
}

/// Domain contract for property data access.
///
/// Implementations live in `home/data/repositories/`.
abstract class PropertyRepository {
  /// Returns a list of properties, optionally filtered.
  ///
  /// When [featured] is `true`, only hero / today's-drops listings are returned.
  Future<Either<Failure, List<Property>>> getProperties({bool featured = false});

  /// Returns properties matching the given [filter] criteria (first page).
  Future<Either<Failure, List<Property>>> searchProperties(SearchFilter filter);

  /// Cursor-paginated Explore search.
  Future<Either<Failure, ExploreSearchResult>> exploreProperties(
    SearchFilter filter, {
    String? cursor,
  });

  /// Viewport map pins for Explore.
  Future<Either<Failure, List<Property>>> exploreMapPins({
    required double north,
    required double south,
    required double east,
    required double west,
    SearchFilter? filter,
  });
}
