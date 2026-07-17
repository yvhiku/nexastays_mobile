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
    final result = await _stays.getProperties(filter: filter);
    return result.fold(Left.new, (list) {
      var mapped = list.map(propertyToHome).toList();
      if (filter.vibes.isNotEmpty) {
        mapped = mapped.where((property) {
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
        mapped = mapped
            .where((property) =>
                entireTypes.contains(property.propertyType.toUpperCase()))
            .toList();
      }
      if (filter.minPrice != null) {
        mapped = mapped
            .where((property) => property.pricePerNight >= filter.minPrice!)
            .toList();
      }
      if (filter.maxPrice != null) {
        mapped = mapped
            .where((property) => property.pricePerNight <= filter.maxPrice!)
            .toList();
      }
      if (filter.minBeds != null) {
        mapped = mapped
            .where((property) => property.bedrooms >= filter.minBeds!)
            .toList();
      }
      return Right(mapped);
    });
  }
}
