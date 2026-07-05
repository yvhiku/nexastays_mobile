import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class GetPropertyDetailUseCase implements UseCase<Property, GetPropertyDetailParams> {
  final PropertyRepository repository;

  GetPropertyDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Property>> call(GetPropertyDetailParams params) async {
    if (params.propertyId.isEmpty) {
      return Left(ValidationFailure('Property ID required'));
    }
    return await repository.getPropertyById(params.propertyId);
  }
}

class GetPropertyDetailParams extends Equatable {
  final String propertyId;

  const GetPropertyDetailParams({
    required this.propertyId,
  });

  @override
  List<Object?> get props => [propertyId];
}
