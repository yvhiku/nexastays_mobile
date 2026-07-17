import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../property/domain/repositories/property_repository.dart'
    as stays_repo;
import '../../../search/domain/entities/search_filter.dart';
import '../../domain/entities/property.dart' as home_entity;
import '../../domain/repositories/property_repository.dart';
import '../mappers/property_to_home_mapper.dart';

/// Bridges the full Stays property stack to the home/search [PropertyRepository].
class HomePropertyRepositoryImpl implements PropertyRepository {
  HomePropertyRepositoryImpl(
      {required stays_repo.PropertyRepository propertyRepository})
      : _stays = propertyRepository;

  final stays_repo.PropertyRepository _stays;

  @override
  Future<Either<Failure, List<home_entity.Property>>> getProperties(
      {bool featured = false}) async {
    final result = await _stays.getProperties(featured: featured);
    return result.fold(
        Left.new, (list) => Right(list.map(propertyToHome).toList()));
  }

  @override
  Future<Either<Failure, List<home_entity.Property>>> searchProperties(
      SearchFilter filter) async {
    final result = await _stays.exploreSearch(filter: filter);
    return result.fold(Left.new, (page) {
      return Right(_applyClientVibeFilters(
          page.properties.map(propertyToHome).toList(), filter));
    });
  }

  @override
  Future<Either<Failure, ExploreSearchResult>> exploreProperties(
    SearchFilter filter, {
    String? cursor,
  }) async {
    final result = await _stays.exploreSearch(filter: filter, cursor: cursor);
    return result.fold(Left.new, (page) {
      final mapped = _applyClientVibeFilters(
        page.properties.map(propertyToHome).toList(),
        filter,
      );
      return Right(ExploreSearchResult(
        properties: mapped,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
      ));
    });
  }

  @override
  Future<Either<Failure, List<home_entity.Property>>> exploreMapPins({
    required double north,
    required double south,
    required double east,
    required double west,
    SearchFilter? filter,
  }) async {
    final result = await _stays.exploreMap(
      north: north,
      south: south,
      east: east,
      west: west,
      filter: filter,
    );
    return result.fold(
      Left.new,
      (list) => Right(list.map(propertyToHome).toList()),
    );
  }

  List<home_entity.Property> _applyClientVibeFilters(
    List<home_entity.Property> mapped,
    SearchFilter filter,
  ) {
    var out = mapped;
    if (filter.vibes.isNotEmpty) {
      out = out.where((property) {
        final haystack = [
          property.propertyType,
          property.city,
          property.description,
          ...property.amenities,
        ].join(' ').toLowerCase();
        return filter.vibes.any((tag) {
          final normalized = tag.toLowerCase();
          if (normalized == 'ocean' || normalized == 'beach') {
            return haystack.contains('ocean') ||
                haystack.contains('beach') ||
                haystack.contains('sea');
          }
          return haystack.contains(normalized);
        });
      }).toList();
    }
    if (filter.guestType == 'entire_place') {
      const entireTypes = {'APARTMENT', 'VILLA', 'RIAD'};
      out = out
          .where((property) =>
              entireTypes.contains(property.propertyType.toUpperCase()))
          .toList();
    }
    if (filter.minPrice != null) {
      out = out
          .where((property) => property.pricePerNight >= filter.minPrice!)
          .toList();
    }
    if (filter.maxPrice != null) {
      out = out
          .where((property) => property.pricePerNight <= filter.maxPrice!)
          .toList();
    }
    if (filter.minBeds != null) {
      out = out
          .where((property) => property.bedrooms >= filter.minBeds!)
          .toList();
    }
    return out;
  }
}
