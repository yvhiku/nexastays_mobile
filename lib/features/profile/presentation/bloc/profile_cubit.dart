import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../identity_verification/domain/entities/verification.dart';
import '../../../identity_verification/domain/repositories/verification_repository.dart';
import '../../../wishlist/domain/repositories/wishlist_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

// =============================================================================
// Profile Cubit
// =============================================================================

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.updateProfileUseCase,
    required this.profileRepository,
    required this.wishlistRepository,
    required this.bookingRepository,
    required this.verificationRepository,
    required this.sessionManager,
    required this.localStorage,
    required this.authBloc,
  }) : super(const ProfileInitial());

  final UpdateProfileUseCase updateProfileUseCase;
  final ProfileRepository profileRepository;
  final WishlistRepository wishlistRepository;
  final BookingRepository bookingRepository;
  final VerificationRepository verificationRepository;
  final SessionManager sessionManager;
  final LocalStorage localStorage;
  final AuthBloc authBloc;

  bool _isAuthInvalidMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('unauthorized') ||
        m.contains('session has expired') ||
        m.contains('token') ||
        m.contains('forbidden') ||
        m.contains('user not found') ||
        m.contains('not found');
  }

  // ── Load profile ─────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    emit(const ProfileLoading());

    final userId = _resolveUserId();
    if (userId == null || userId.isEmpty) {
      emit(ProfileError(
        message: 'Please sign in',
        currentUser: _currentAuthUser(),
      ));
      return;
    }

    // Fetch profile, bookings, wishlist IDs, and verification in parallel.
    final results = await Future.wait([
      profileRepository.getProfile(userId),             // 0
      bookingRepository.getGuestBookings(userId),        // 1
      wishlistRepository.getSavedPropertyIds(userId),    // 2
      verificationRepository.getVerificationStatus(      // 3
        userId: userId,
      ),
    ]);

    final profileResult = results[0] as Either<Failure, User>;
    final bookingsResult = results[1] as Either<Failure, List>;
    final wishlistResult = results[2] as Either<Failure, Set>;
    final verificationResult = results[3] as Either<Failure, Verification>;

    // Profile is critical — fail if it can't be loaded.
    profileResult.fold(
      (failure) {
        if (_isAuthInvalidMessage(failure.message)) {
          authBloc.add(AuthLogoutRequested());
          emit(const ProfileDeleted());
          return;
        }
        emit(ProfileError(
          message: failure.message,
          currentUser: _currentAuthUser(),
        ));
      },
      (profileData) {
        final user = profileData;

        // Bookings count (graceful fallback).
        int totalBookings = 0;
        bookingsResult.fold(
          (_) {},
          (bookings) => totalBookings = bookings.length,
        );

        // Wishlist count (graceful fallback).
        int savedCount = 0;
        wishlistResult.fold(
          (_) {},
          (ids) => savedCount = ids.length,
        );

        // Verification status (graceful fallback). Unified KYC from `/users/me`
        // wins over Stays host verification when the user is already verified
        // in another consumer app (e.g. Nexa Pay).
        VerificationStatus vStatus = VerificationStatus.notStarted;
        verificationResult.fold(
          (_) {},
          (verification) => vStatus = verification.status,
        );
        if (user.isVerified) {
          vStatus = VerificationStatus.approved;
        }

        // Read cached preferences.
        _loadPreferences(userId).then((prefs) {
          if (!isClosed) {
            emit(ProfileLoaded(
              user: user,
              totalBookings: totalBookings,
              savedPropertiesCount: savedCount,
              verificationStatus: vStatus,
              notificationPreferences: prefs.$1,
              languageCode: prefs.$2,
            ));
          }
        });
      },
    );
  }

  String? _resolveUserId() {
    final fromSession = sessionManager.userId;
    if (fromSession != null && fromSession.isNotEmpty) return fromSession;
    return _currentAuthUser()?.id;
  }

  User? _currentAuthUser() {
    final state = authBloc.state;
    if (state is AuthAuthenticated) return state.user;
    if (state is AuthOtpVerified) return state.user;
    if (state is AuthPersonalInfoSaved) return state.user;
    if (state is AuthPinSuccess) return state.user;
    return null;
  }

  Future<(Map<String, bool>, String)> _loadPreferences(
    String userId,
  ) async {
    Map<String, bool> notifPrefs = {};
    String langCode = 'en';

    try {
      final langRaw = await localStorage.getString('user_language');
      if (langRaw != null && langRaw.isNotEmpty) langCode = langRaw;
    } catch (_) {}

    try {
      final notifRaw = await localStorage.getString(
        'notification_prefs_$userId',
      );
      if (notifRaw != null && notifRaw.isNotEmpty) {
        // Simple key=true/false parsing.
        // In production, use jsonDecode. Kept simple for now.
      }
    } catch (_) {}

    return (notifPrefs, langCode);
  }

  // ── Update profile ───────────────────────────────────────────────────

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profilePhotoPath,
  }) async {
    final s = state;
    if (s is! ProfileLoaded) return;

    emit(ProfileUpdating(currentUser: s.user));

    final result = await updateProfileUseCase(UpdateProfileParams(
      userId: s.user.id,
      identityLocked: s.user.isVerified,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      profilePhotoPath: profilePhotoPath,
    ));

    result.fold(
      (failure) {
        emit(ProfileError(
          message: failure.message,
          currentUser: s.user,
        ));
      },
      (updatedUser) {
        emit(ProfileUpdateSuccess(updatedUser: updatedUser));
        emit(s.copyWith(
          user: updatedUser,
          isUpdating: false,
          profilePhotoRevision: profilePhotoPath != null
              ? s.profilePhotoRevision + 1
              : s.profilePhotoRevision,
        ));
      },
    );
  }

  // ── Change password ──────────────────────────────────────────────────

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final s = state;
    if (s is! ProfileLoaded) return;

    final result = await profileRepository.changePassword(
      userId: s.user.id,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(PasswordChangeError(message: failure.message)),
      (_) => emit(const PasswordChangeSuccess()),
    );
  }

  // ── Notification preferences ─────────────────────────────────────────

  Future<void> updateNotificationPref(String key, bool value) async {
    final s = state;
    if (s is! ProfileLoaded) return;

    final previous = s.notificationPreferences;
    final updated = {...previous, key: value};

    // Optimistic update.
    emit(s.copyWith(notificationPreferences: updated));

    final result = await profileRepository.updateNotificationPreferences(
      userId: s.user.id,
      preferences: updated,
    );

    result.fold(
      (failure) {
        // Revert on failure.
        final current = state;
        if (current is ProfileLoaded) {
          emit(current.copyWith(notificationPreferences: previous));
        }
        emit(ProfileError(
          message: failure.message,
          currentUser: s.user,
        ));
      },
      (_) {}, // Already optimistically applied.
    );
  }

  // ── Language preference ──────────────────────────────────────────────

  Future<void> updateLanguage(String langCode) async {
    final s = state;
    if (s is! ProfileLoaded) return;

    // Optimistic update.
    emit(s.copyWith(languageCode: langCode));

    final result = await profileRepository.updateLanguagePreference(
      userId: s.user.id,
      languageCode: langCode,
    );

    result.fold(
      (failure) {
        // Revert on failure.
        final current = state;
        if (current is ProfileLoaded) {
          emit(current.copyWith(languageCode: s.languageCode));
        }
      },
      (_) {},
    );
  }

  // ── Logout ───────────────────────────────────────────────────────────

  void logout() {
    authBloc.add(AuthLogoutRequested());
  }

  // ── Delete account ───────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    final userId = sessionManager.userId;
    if (userId == null) return;

    emit(const ProfileDeleting());

    final result = await profileRepository.deleteAccount(userId);

    result.fold(
      (failure) {
        // If account was already removed server-side, force local logout.
        if (_isAuthInvalidMessage(failure.message)) {
          authBloc.add(AuthLogoutRequested());
          emit(const ProfileDeleted());
          return;
        }
        emit(ProfileError(message: failure.message));
      },
      (_) {
        // Ensure all auth-dependent features are reset consistently.
        authBloc.add(AuthLogoutRequested());
        emit(const ProfileDeleted());
      },
    );
  }
}
