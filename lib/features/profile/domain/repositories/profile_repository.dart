import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';

// =============================================================================
// Profile Repository (Abstract Interface)
// =============================================================================

/// Contract for profile operations.
///
/// All methods return `Future<Either<Failure, T>>` so callers can
/// react without exceptions.
abstract class ProfileRepository {
  /// Fetches the user profile from the remote server.
  Future<Either<Failure, User>> getProfile(String userId);

  /// Updates user profile fields. Only non-null fields are sent.
  ///
  /// [profilePhotoPath] is a local file path that will be uploaded.
  /// When [identityLocked] is true (verified KYC), [firstName] / [lastName]
  /// are not sent to the API.
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    bool identityLocked = false,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profilePhotoPath,
  });

  /// Changes the user's password.
  Future<Either<Failure, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  /// Permanently deletes the user's account.
  Future<Either<Failure, void>> deleteAccount(String userId);

  /// Updates push notification preferences.
  ///
  /// [preferences] is a map of preference keys to enabled/disabled:
  /// e.g. `{'bookings': true, 'promotions': false}`.
  Future<Either<Failure, void>> updateNotificationPreferences({
    required String userId,
    required Map<String, bool> preferences,
  });

  /// Updates the user's preferred language.
  ///
  /// [languageCode] is one of `'en'`, `'ar'`, or `'fr'`.
  Future<Either<Failure, void>> updateLanguagePreference({
    required String userId,
    required String languageCode,
  });

  /// Returns the locally cached profile (offline-first).
  Future<Either<Failure, User>> getCachedProfile(String userId);
}
