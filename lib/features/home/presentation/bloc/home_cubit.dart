import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../host_dashboard/domain/repositories/host_repository.dart';
import '../../domain/usecases/get_properties_usecase.dart';
import 'home_state.dart';

/// Cubit that drives the NexaStays home screen.
///
/// Fetches featured & trending properties, resolves the current user
/// from [SessionManager], and emits [HomeLoaded] or [HomeError].
class HomeCubit extends Cubit<HomeState> {
  final GetPropertiesUseCase _getPropertiesUseCase;
  final SessionManager _sessionManager;
  final LocalStorage _localStorage;
  final HostRepository? _hostRepository;

  HomeCubit({
    required GetPropertiesUseCase getPropertiesUseCase,
    required SessionManager sessionManager,
    required LocalStorage localStorage,
    HostRepository? hostRepository,
  })  : _getPropertiesUseCase = getPropertiesUseCase,
        _sessionManager = sessionManager,
        _localStorage = localStorage,
        _hostRepository = hostRepository,
        super(const HomeInitial());

  // ── Public API ──────────────────────────────────────────────────────────

  /// Loads all data required by the home screen.
  ///
  /// Flow:
  /// 1. Emit [HomeLoading].
  /// 2. Fetch featured properties via [GetPropertiesUseCase].
  /// 3. Split results → hero (first item) + today's drops (next 4).
  /// 4. Build trending list from the remaining items.
  /// 5. Resolve current [User] from `cached_user` (written at login from `/users/me`).
  /// 6. Emit [HomeLoaded] or [HomeError].
  Future<void> loadHome() async {
    emit(const HomeLoading());

    final result = await _getPropertiesUseCase(
      const GetPropertiesParams(featured: true),
    );

    await result.fold<Future<void>>(
      (failure) async {
        emit(HomeError(message: failure.message));
      },
      (properties) async {
        // Hero banner  → first property
        // Today's Drops → next 4 properties
        final featuredProperties = properties.take(5).toList();

        // Trending     → the rest of the list
        final trendingProperties =
            properties.length > 5 ? properties.sublist(5) : <dynamic>[];

        // Unique destination city names
        final destinations = properties
            .map((p) => p.city)
            .toSet()
            .toList();

        // Current authenticated user (same cache as auth: /users/me after login)
        final currentUser = await _resolveCurrentUser();
        final showBecomeHostBanner =
            await _resolveShowBecomeHostBanner(currentUser);

        emit(HomeLoaded(
          featuredProperties: featuredProperties,
          trendingProperties: trendingProperties.cast(),
          destinations: destinations,
          currentUser: currentUser,
          showBecomeHostBanner: showBecomeHostBanner,
        ));
      },
    );
  }

  /// Convenience alias — pulls fresh data.
  Future<void> refresh() => loadHome();

  // ── Private helpers ─────────────────────────────────────────────────────

  /// Whether to show the home "Become a Host" card (matches web NavBar logic).
  Future<bool> _resolveShowBecomeHostBanner(User user) async {
    if (user.id == 'guest' || user.id.isEmpty) {
      return true;
    }

    final hostRepo = _hostRepository;
    if (hostRepo == null) {
      return !user.isHost;
    }

    final result = await hostRepo.getHostMe();
    return result.fold(
      (_) => true,
      (hostMe) => hostMe.shouldShowBecomeHostBanner,
    );
  }

  /// Resolves the signed-in user from [LocalStorage] `cached_user` (filled by auth).
  Future<User> _resolveCurrentUser() async {
    final cached = await _localStorage.getString('cached_user');
    if (cached != null && cached.isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      } catch (_) {}
    }

    final uid = _sessionManager.userId;
    if (uid != null && uid.isNotEmpty) {
      return User(
        id: uid,
        phone: '',
        fullName: '',
        dateOfBirth: DateTime(2000, 1, 1),
        isMoroccan: true,
        hasPin: false,
        isVerified: false,
        isHost: false,
        onboardingStep: OnboardingStep.personalInfo,
        createdAt: DateTime.now(),
      );
    }

    return User(
      id: 'guest',
      phone: '',
      fullName: 'Guest',
      dateOfBirth: DateTime(2000, 1, 1),
      isMoroccan: true,
      hasPin: false,
      isVerified: false,
      isHost: false,
      onboardingStep: OnboardingStep.phoneEntry,
      createdAt: DateTime.now(),
    );
  }
}
