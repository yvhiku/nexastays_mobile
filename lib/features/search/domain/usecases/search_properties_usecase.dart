import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/property.dart';
import '../../../home/domain/repositories/property_repository.dart';
import '../entities/search_filter.dart';

/// Searches properties using the provided [SearchFilter].
///
/// Validates that a city is selected before delegating to [PropertyRepository].
class SearchPropertiesUseCase
    implements UseCase<List<Property>, SearchFilter> {
  final PropertyRepository repository;

  SearchPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Property>>> call(SearchFilter params) async {
    return await repository.searchProperties(params);
  }
}
