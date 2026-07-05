import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Fetches a list of properties with an optional [featured] filter.
class GetPropertiesUseCase
    implements UseCase<List<Property>, GetPropertiesParams> {
  final PropertyRepository repository;

  GetPropertiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Property>>> call(
    GetPropertiesParams params,
  ) async {
    return await repository.getProperties(featured: params.featured);
  }
}

/// Parameters for [GetPropertiesUseCase].
class GetPropertiesParams extends Equatable {
  final bool featured;

  const GetPropertiesParams({this.featured = false});

  @override
  List<Object?> get props => [featured];
}
