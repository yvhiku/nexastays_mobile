import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../search/domain/entities/search_filter.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class GetPropertiesUseCase implements UseCase<List<Property>, GetPropertiesParams> {
  final PropertyRepository repository;

  GetPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Property>>> call(GetPropertiesParams params) async {
    return await repository.getProperties(
      filter: params.filter,
      featured: params.featured,
      trending: params.trending,
    );
  }
}

class GetPropertiesParams extends Equatable {
  final SearchFilter? filter;
  final bool featured;
  final bool trending;

  const GetPropertiesParams({
    this.filter,
    this.featured = false,
    this.trending = false,
  });

  @override
  List<Object?> get props => [filter, featured, trending];
}
