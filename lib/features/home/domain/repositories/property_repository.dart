import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../search/domain/entities/search_filter.dart';
import '../entities/property.dart';

/// Domain contract for property data access.
///
/// Implementations live in `home/data/repositories/`.
abstract class PropertyRepository {
  /// Returns a list of properties, optionally filtered.
  ///
  /// When [featured] is `true`, only hero / today's-drops listings are returned.
  Future<Either<Failure, List<Property>>> getProperties({bool featured = false});

  /// Returns properties matching the given [filter] criteria.
  Future<Either<Failure, List<Property>>> searchProperties(SearchFilter filter);
}
