import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

// =============================================================================
// Update Profile Use Case
// =============================================================================

/// Validates profile fields and delegates to [ProfileRepository.updateProfile].
class UpdateProfileUseCase extends UseCase<User, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  static final _phoneRegex = RegExp(r'^\+[1-9]\d{7,14}$');

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    // ── Validation ───────────────────────────────────────────────────

    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User not authenticated'));
    }

    final firstName =
        params.identityLocked ? null : params.firstName;
    final lastName = params.identityLocked ? null : params.lastName;

    if (firstName == null &&
        lastName == null &&
        params.phone == null &&
        params.email == null &&
        params.profilePhotoPath == null) {
      return const Left(ValidationFailure('No changes to save'));
    }

    if (firstName != null && firstName.isEmpty) {
      return const Left(ValidationFailure('First name cannot be empty'));
    }

    if (lastName != null && lastName.isEmpty) {
      return const Left(ValidationFailure('Last name cannot be empty'));
    }

    if (params.email != null &&
        (!params.email!.contains('@') || !params.email!.contains('.'))) {
      return const Left(ValidationFailure('Invalid email address'));
    }

    final phone = params.phone != null
        ? normalizePhone(params.phone!)
        : null;
    if (phone != null && !_phoneRegex.hasMatch(phone)) {
      return const Left(
        ValidationFailure('Invalid phone number'),
      );
    }

    // ── Delegate ─────────────────────────────────────────────────────

    return _repository.updateProfile(
      userId: params.userId,
      identityLocked: params.identityLocked,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: params.email,
      profilePhotoPath: params.profilePhotoPath,
    );

    // NOTE: Caller (Cubit) is responsible for updating SessionManager /
    // local cache with the returned User, since SessionManager only
    // stores userId + tokens, not the full User object.
  }
}

// =============================================================================
// Params
// =============================================================================

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    required this.userId,
    this.identityLocked = false,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.profilePhotoPath,
  });

  final String userId;

  /// When true (KYC verified), [firstName] / [lastName] are ignored — name
  /// must match the verified document.
  final bool identityLocked;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;

  /// Local file path for the new profile photo.
  final String? profilePhotoPath;

  @override
  List<Object?> get props => [
        userId,
        identityLocked,
        firstName,
        lastName,
        phone,
        email,
        profilePhotoPath,
      ];
}
