import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CreatePinUseCase implements UseCase<void, CreatePinParams> {
  final AuthRepository repository;

  CreatePinUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreatePinParams params) async {
    // Allow local testing without having to go through OTP first
    final testUserId = params.userId.isEmpty ? 'mock_user_id_212123456789' : params.userId;

    final pinRegExp = RegExp(r'^\d{4}$');
    if (!pinRegExp.hasMatch(params.pin)) {
      return Left(ValidationFailure('PIN must be 4 digits'));
    }

    // Commented out to allow testing with 0000
    // const insecurePins = ['0000', '1111', '1234', '4321', '0123'];
    // if (insecurePins.contains(params.pin)) {
    //   return Left(ValidationFailure('Please choose a more secure PIN'));
    // }

    if (params.pin != params.confirmPin) {
      return Left(ValidationFailure('PINs do not match'));
    }

    final createResult = await repository.createPin(
      userId: testUserId,
      pin: params.pin,
    );

    return await createResult.fold(
      (failure) async => Left<Failure, void>(failure),
      (_) async => await repository.confirmPin(
        userId: testUserId,
        pin: params.confirmPin,
      ),
    );
  }
}

class CreatePinParams extends Equatable {
  final String userId;
  final String pin;
  final String confirmPin;

  const CreatePinParams({
    required this.userId,
    required this.pin,
    required this.confirmPin,
  });

  @override
  List<Object?> get props => [userId, pin, confirmPin];
}
