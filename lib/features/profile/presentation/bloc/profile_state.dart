import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../identity_verification/domain/entities/verification.dart';

// =============================================================================
// Profile States
// =============================================================================

/// Base state for the profile feature.
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state — nothing loaded yet.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading the profile from remote / cache.
final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile data is fully loaded.
final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    this.isHost = false,
    this.totalBookings = 0,
    this.savedPropertiesCount = 0,
    this.verificationStatus = VerificationStatus.notStarted,
    this.notificationPreferences = const {},
    this.languageCode = 'en',
    this.isUpdating = false,
    this.profilePhotoRevision = 0,
  });

  final User user;
  final bool isHost;
  final int totalBookings;
  final int savedPropertiesCount;
  final VerificationStatus verificationStatus;
  final Map<String, bool> notificationPreferences;

  /// `'en'`, `'ar'`, or `'fr'`.
  final String languageCode;

  /// Bumped after photo upload so authenticated image URLs cache-bust.
  final int profilePhotoRevision;

  /// `true` while a profile update is in progress.
  final bool isUpdating;

  ProfileLoaded copyWith({
    User? user,
    bool? isHost,
    int? totalBookings,
    int? savedPropertiesCount,
    VerificationStatus? verificationStatus,
    Map<String, bool>? notificationPreferences,
    String? languageCode,
    bool? isUpdating,
    int? profilePhotoRevision,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isHost: isHost ?? this.isHost,
      totalBookings: totalBookings ?? this.totalBookings,
      savedPropertiesCount:
          savedPropertiesCount ?? this.savedPropertiesCount,
      verificationStatus:
          verificationStatus ?? this.verificationStatus,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      languageCode: languageCode ?? this.languageCode,
      isUpdating: isUpdating ?? this.isUpdating,
      profilePhotoRevision:
          profilePhotoRevision ?? this.profilePhotoRevision,
    );
  }

  @override
  List<Object?> get props => [
        user,
        isHost,
        totalBookings,
        savedPropertiesCount,
        verificationStatus,
        notificationPreferences,
        languageCode,
        isUpdating,
        profilePhotoRevision,
      ];
}

/// Profile is being updated (retain current data in the UI).
final class ProfileUpdating extends ProfileState {
  const ProfileUpdating({required this.currentUser});

  final User currentUser;

  @override
  List<Object?> get props => [currentUser];
}

/// Profile was successfully updated.
final class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess({required this.updatedUser});

  final User updatedUser;

  @override
  List<Object?> get props => [updatedUser];
}

/// An error occurred. [currentUser] retains data on non-fatal errors.
final class ProfileError extends ProfileState {
  const ProfileError({
    required this.message,
    this.currentUser,
  });

  final String message;
  final User? currentUser;

  @override
  List<Object?> get props => [message, currentUser];
}

/// Account is being deleted.
final class ProfileDeleting extends ProfileState {
  const ProfileDeleting();
}

/// Account deleted — trigger logout + clear all data.
final class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}

/// Password was changed successfully.
final class PasswordChangeSuccess extends ProfileState {
  const PasswordChangeSuccess();
}

/// Password change failed.
final class PasswordChangeError extends ProfileState {
  const PasswordChangeError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
