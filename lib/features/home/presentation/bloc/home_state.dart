import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/property.dart';

// ─── NEXASTAYS HOME FEATURE — STATE CONTRACT ────────────────────────────────
// HomeInitial   → default / idle
// HomeLoading   → data is being fetched
// HomeLoaded    → all home-screen data ready
// HomeError     → something went wrong
// ─────────────────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Default state before any action is dispatched.
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Emitted while home data is being fetched.
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Emitted when all home-screen data has been loaded successfully.
///
/// • [featuredProperties] – hero banner + today's drops
/// • [trendingProperties] – trending / popular listings
/// • [destinations]       – city names (with images resolved elsewhere)
/// • [currentUser]        – the authenticated user
class HomeLoaded extends HomeState {
  final List<Property> featuredProperties;

  /// Curated Featured Deals for the launch feed.
  final List<Property> trendingProperties;
  final List<Property> topRatedProperties;
  final List<String> destinations;
  final Map<String, int> destinationCounts;
  final User currentUser;
  final bool showBecomeHostBanner;

  const HomeLoaded({
    required this.featuredProperties,
    required this.trendingProperties,
    required this.topRatedProperties,
    required this.destinations,
    required this.destinationCounts,
    required this.currentUser,
    this.showBecomeHostBanner = true,
  });

  @override
  List<Object?> get props => [
        featuredProperties,
        trendingProperties,
        topRatedProperties,
        destinations,
        destinationCounts,
        currentUser,
        showBecomeHostBanner,
      ];
}

/// Emitted when loading home data fails.
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
