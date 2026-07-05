import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../property/domain/repositories/property_repository.dart' as stays_repo;
import '../../../search/domain/entities/search_filter.dart';
import '../../domain/entities/property.dart' as home_entity;
import '../../domain/repositories/property_repository.dart';
import '../mappers/property_to_home_mapper.dart';

/// Bridges the full Stays property stack to the home/search [PropertyRepository].
class HomePropertyRepositoryImpl implements PropertyRepository {
  HomePropertyRepositoryImpl({required stays_repo.PropertyRepository propertyRepository})
      : _stays = propertyRepository;

  final stays_repo.PropertyRepository _stays;

  @override
  Future<Either<Failure, List<home_entity.Property>>> getProperties({bool featured = false}) async {
    final result = await _stays.getProperties(featured: featured);
    return result.fold(Left.new, (list) => Right(list.map(propertyToHome).toList()));
  }

  @override
  Future<Either<Failure, List<home_entity.Property>>> searchProperties(SearchFilter filter) async {
    final result = await _stays.getProperties(filter: filter);
    return result.fold(Left.new, (list) => Right(list.map(propertyToHome).toList()));
  }
}
