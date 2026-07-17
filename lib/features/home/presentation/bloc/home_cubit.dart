import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../host_dashboard/domain/repositories/host_repository.dart';
import '../../domain/entities/property.dart';
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
  /// 3. Curate hero, Featured Deals and Top Rated without repetition.
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
        final rankedHero = List<Property>.from(properties)
          ..sort((a, b) => _heroScore(b).compareTo(_heroScore(a)));
        final heroCandidates = rankedHero.take(3).toList();
        final hero = heroCandidates.isEmpty
            ? <Property>[]
            : <Property>[
                heroCandidates[DateTime.now().day % heroCandidates.length],
              ];
        final usedIds = hero.map((property) => property.id).toSet();

        final newest = List<Property>.from(properties)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final featuredDeals = newest
            .where((property) => !usedIds.contains(property.id))
            .take(4)
            .toList();
        usedIds.addAll(featuredDeals.map((property) => property.id));

        final topRated = List<Property>.from(properties)
          ..sort((a, b) {
            final reviewComparison = b.reviewCount.compareTo(a.reviewCount);
            if (reviewComparison != 0) return reviewComparison;
            return b.rating.compareTo(a.rating);
          });
        final topRatedUnique = topRated
            .where((property) =>
                property.reviewCount > 0 && !usedIds.contains(property.id))
            .take(4)
            .toList();

        final destinationCounts = <String, int>{};
        for (final property in properties) {
          final city = property.city.trim();
          if (city.isEmpty) continue;
          destinationCounts[city] = (destinationCounts[city] ?? 0) + 1;
        }
        final destinations = destinationCounts.keys.toList()
          ..sort(
              (a, b) => destinationCounts[b]!.compareTo(destinationCounts[a]!));

        // Current authenticated user (same cache as auth: /users/me after login)
        final currentUser = await _resolveCurrentUser();
        final showBecomeHostBanner =
            await _resolveShowBecomeHostBanner(currentUser);

        emit(HomeLoaded(
          featuredProperties: hero,
          trendingProperties: featuredDeals,
          topRatedProperties: topRatedUnique,
          destinations: destinations,
          destinationCounts: destinationCounts,
          currentUser: currentUser,
          showBecomeHostBanner: showBecomeHostBanner,
        ));
      },
    );
  }

  /// Convenience alias — pulls fresh data.
  Future<void> refresh() => loadHome();

  int _heroScore(Property property) {
    var score = 0;
    if (property.isVerified) score += 40;
    if (property.imageUrl.trim().isNotEmpty) score += 30;
    if (property.reviewCount > 0) {
      score += (property.rating * 6).round();
    }
    if (property.isInstantBook) score += 15;
    final age = DateTime.now().difference(property.createdAt).inDays;
    if (age <= 30) score += 10;
    return score;
  }

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
