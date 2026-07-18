import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<User, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyOtpParams params) async {
    if (params.phone.isEmpty) {
      return Left(ValidationFailure('Please enter a valid phone number'));
    }

    final otpRegExp = RegExp(r'^\d{6}$');
    if (!otpRegExp.hasMatch(params.otp)) {
      return Left(ValidationFailure('Please enter the 6-digit code'));
    }

    return await repository.verifyOtp(
      phone: normalizePhone(params.phone),
      otp: params.otp,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otp;

  const VerifyOtpParams({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

class SavePersonalInfoUseCase implements UseCase<User, SavePersonalInfoParams> {
  final AuthRepository repository;

  SavePersonalInfoUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SavePersonalInfoParams params) async {
    if (params.userId.isEmpty) {
      return Left(ValidationFailure('Not authenticated'));
    }

    if (params.fullName.trim().isEmpty) {
      return Left(ValidationFailure('Please enter your full name'));
    }

    final wordCount = params.fullName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .length;
    if (wordCount < 2) {
      return Left(ValidationFailure('Please enter your full name as on your document'));
    }

    final ageInDays = DateTime.now().difference(params.dateOfBirth).inDays;
    if (ageInDays < 365 * 18) {
      return Left(ValidationFailure('You must be at least 18 years old'));
    }

    if (!params.isMoroccan &&
        (params.countryOfCitizenship == null || params.countryOfCitizenship!.isEmpty)) {
      return Left(ValidationFailure('Please select your country of citizenship'));
    }

    return await repository.savePersonalInfo(
      userId: params.userId,
      fullName: params.fullName,
      dateOfBirth: params.dateOfBirth,
      isMoroccan: params.isMoroccan,
      email: params.email,
      city: params.city,
      nationality: params.nationality,
      countryOfCitizenship: params.countryOfCitizenship,
    );
  }
}

class SavePersonalInfoParams extends Equatable {
  final String userId;
  final String fullName;
  final DateTime dateOfBirth;
  final bool isMoroccan;
  final String? email;
  final String? city;
  final String? nationality;
  final String? countryOfCitizenship;

  const SavePersonalInfoParams({
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.isMoroccan,
    this.email,
    this.city,
    this.nationality,
    this.countryOfCitizenship,
  });

  @override
  List<Object?> get props => [
        userId,
        fullName,
        dateOfBirth,
        isMoroccan,
        email,
        city,
        nationality,
        countryOfCitizenship,
      ];
}

class CompleteKycUseCase implements UseCase<User, CompleteKycParams> {
  final AuthRepository repository;

  CompleteKycUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(CompleteKycParams params) async {
    if (params.fullName.trim().isEmpty) {
      return Left(ValidationFailure('Please enter your full name'));
    }

    final wordCount = params.fullName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .length;
    if (wordCount < 2) {
      return Left(
        ValidationFailure('Please enter your full name as on your document'),
      );
    }

    final ageInDays = DateTime.now().difference(params.dateOfBirth).inDays;
    if (ageInDays < 365 * 18) {
      return Left(ValidationFailure('You must be at least 18 years old'));
    }

    if (params.city == null || params.city!.trim().isEmpty) {
      return Left(ValidationFailure('Please enter your city'));
    }

    final personalInfoResult = await repository.submitKycPersonalInfo(
      fullName: params.fullName,
      dateOfBirth: params.dateOfBirth,
      isMoroccan: params.isMoroccan,
      email: params.email,
      city: params.city,
      nationality: params.nationality,
    );

    return await personalInfoResult.fold(
      (failure) async => Left<Failure, User>(failure),
      (_) async {
        final verificationResult = await repository.launchSumsubVerification();
        return await verificationResult.fold(
          (failure) async => Left<Failure, User>(failure),
          (approved) async {
            if (!approved) {
              return Left(
                ServerFailure(
                  'Verification submitted. Please wait for approval.',
                ),
              );
            }
            return await repository.refreshCurrentUser();
          },
        );
      },
    );
  }
}

class CompleteKycParams extends Equatable {
  final String fullName;
  final DateTime dateOfBirth;
  final bool isMoroccan;
  final String? email;
  final String? city;
  final String? nationality;

  const CompleteKycParams({
    required this.fullName,
    required this.dateOfBirth,
    required this.isMoroccan,
    this.email,
    this.city,
    this.nationality,
  });

  @override
  List<Object?> get props => [
        fullName,
        dateOfBirth,
        isMoroccan,
        email,
        city,
        nationality,
      ];
}
