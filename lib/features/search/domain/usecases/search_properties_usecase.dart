import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/repositories/property_repository.dart';
import '../entities/search_filter.dart';

/// Searches properties using the provided [SearchFilter] with cursor pagination.
class SearchPropertiesUseCase
    implements UseCase<ExploreSearchResult, SearchPropertiesParams> {
  final PropertyRepository repository;

  SearchPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, ExploreSearchResult>> call(
    SearchPropertiesParams params,
  ) async {
    return await repository.exploreProperties(
      params.filter,
      cursor: params.cursor,
    );
  }
}

class SearchPropertiesParams {
  const SearchPropertiesParams({
    required this.filter,
    this.cursor,
  });

  final SearchFilter filter;
  final String? cursor;
}
