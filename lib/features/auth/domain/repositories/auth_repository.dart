import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  // Step 1 — phone entry
  Future<Either<Failure, void>> sendOtp(String phone);

  // Step 2 — OTP verification
  // Returns partial User (onboardingStep = personalInfo if new user)
  // Returns complete User (onboardingStep = complete if returning user)
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  });

  // Step 3 — personal info
  Future<Either<Failure, User>> savePersonalInfo({
    required String userId,
    required String fullName,
    required DateTime dateOfBirth,
    required bool isMoroccan,
    String? email,
    String? city,
    String? nationality,
    String? countryOfCitizenship,
  });

  Future<Either<Failure, void>> submitKycPersonalInfo({
    required String fullName,
    required DateTime dateOfBirth,
    required bool isMoroccan,
    String? email,
    String? city,
    String? nationality,
  });

  Future<Either<Failure, bool>> launchSumsubVerification();

  Future<Either<Failure, User>> refreshCurrentUser();

  // Step 5 — PIN setup (steps 4 = identity_verification feature)
  Future<Either<Failure, void>> createPin({
    required String userId,
    required String pin,
  });

  Future<Either<Failure, void>> confirmPin({
    required String userId,
    required String pin,
  });

  // Returning user login
  Future<Either<Failure, User>> loginWithPin({
    required String phone,
    required String pin,
  });

  // Utilities
  Future<Either<Failure, void>> resendOtp(String phone);
  
  Future<Either<Failure, User?>> getCachedUser();
  
  Future<Either<Failure, void>> logout();
}
