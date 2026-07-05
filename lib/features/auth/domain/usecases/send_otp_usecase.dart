import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase implements UseCase<void, SendOtpParams> {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendOtpParams params) async {
    if (params.phone.isEmpty) {
      return Left(ValidationFailure('Please enter a valid Moroccan phone number'));
    }

    final phone = normalizeMoroccoPhone(params.phone);
    final phoneRegExp = RegExp(r'^\+212[0-9]{9}$');
    if (!phoneRegExp.hasMatch(phone)) {
      return Left(ValidationFailure('Please enter a valid Moroccan phone number'));
    }

    return await repository.sendOtp(phone);
  }
}

class SendOtpParams extends Equatable {
  final String phone;

  const SendOtpParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class LoginWithPinUseCase implements UseCase<User, LoginWithPinParams> {
  final AuthRepository repository;

  LoginWithPinUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginWithPinParams params) async {
    final phone = normalizeMoroccoPhone(params.phone);
    final phoneRegExp = RegExp(r'^\+212[0-9]{9}$');
    if (!phoneRegExp.hasMatch(phone)) {
      return Left(ValidationFailure('Invalid phone number'));
    }

    final pinRegExp = RegExp(r'^\d{4}$');
    if (!pinRegExp.hasMatch(params.pin)) {
      return Left(ValidationFailure('PIN must be 4 digits'));
    }

    return await repository.loginWithPin(
      phone: phone,
      pin: params.pin,
    );
  }
}

class LoginWithPinParams extends Equatable {
  final String phone;
  final String pin;

  const LoginWithPinParams({
    required this.phone,
    required this.pin,
  });

  @override
  List<Object?> get props => [phone, pin];
}
