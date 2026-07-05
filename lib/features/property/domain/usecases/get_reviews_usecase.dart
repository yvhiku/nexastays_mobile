import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing_reviews_result.dart';
import '../repositories/property_repository.dart';

class GetReviewsUseCase implements UseCase<ListingReviewsResult, GetReviewsParams> {
  final PropertyRepository repository;

  GetReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, ListingReviewsResult>> call(GetReviewsParams params) async {
    if (params.propertyId.isEmpty) {
      return Left(ValidationFailure('Property ID required'));
    }
    return await repository.getReviews(
      propertyId: params.propertyId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetReviewsParams extends Equatable {
  final String propertyId;
  final int page;
  final int limit;

  const GetReviewsParams({
    required this.propertyId,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [propertyId, page, limit];
}
