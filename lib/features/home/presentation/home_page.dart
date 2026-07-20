import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/components/nexa_stays_wordmark.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../navigation/app_routes.dart';
import '../../messaging/presentation/inbox/inbox_cubit.dart';
import '../../messaging/presentation/inbox/inbox_state.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profile/presentation/widgets/profile_photo_avatar.dart';
import 'bloc/home_cubit.dart';
import 'bloc/home_state.dart';
import 'widgets/destination_cards.dart';
import 'widgets/hero_section.dart';
import 'widgets/featured_stays.dart';
import 'widgets/host_banner.dart';
import 'widgets/trending_destinations.dart';

/// Main home screen for NexaStays.
///
/// Uses [BlocConsumer] to react to [HomeCubit] state changes and
/// assembles all home-page sections inside a scrollable body with
/// a fixed [BottomNavigationBar].
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
    context.read<InboxCubit>().loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return _buildShimmer();
          }
          if (state is HomeError) {
            return _buildError(state.message);
          }
          if (state is HomeLoaded) {
            return _buildContent(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AppBar
  // ═══════════════════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 180,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: NexaStaysBrandRow(
            logoSize: 32,
            fontSize: 20,
          ),
        ),
      ),
      actions: [
        BlocBuilder<InboxCubit, InboxState>(
          builder: (context, inboxState) {
            final unread = switch (inboxState) {
              InboxLoaded(:final unreadCount) => unreadCount,
              InboxEmpty(:final unreadCount) => unreadCount,
              InboxUnreadLoaded(:final unreadCount) => unreadCount,
              _ => 0,
            };
            final badge = unread <= 0
                ? null
                : (unread > 99 ? '99+' : '$unread');
            return IconButton(
              tooltip: 'Messages',
              onPressed: () => context.push(AppRoutes.inbox),
              icon: Badge(
                isLabelVisible: badge != null,
                label: badge != null ? Text(badge) : null,
                backgroundColor: DSColors.primary,
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final profilePhotoUrl = state is HomeLoaded
                  ? state.currentUser.profilePhotoUrl
                  : null;
              final initial = state is HomeLoaded
                  ? (state.currentUser.firstName.isNotEmpty
                      ? state.currentUser.firstName[0].toUpperCase()
                      : 'U')
                  : 'U';
              return GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: ProfilePhotoAvatar(
                  profilePhotoUrl: profilePhotoUrl,
                  radius: 18,
                  fallback: Text(
                    initial,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Main content (HomeLoaded)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildContent(HomeLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSearchBar(),
          const SizedBox(height: 22),
          if (state.featuredProperties.isNotEmpty) ...[
            _Reveal(
              delay: const Duration(milliseconds: 80),
              child: HeroSection(property: state.featuredProperties.first),
            ),
            const SizedBox(height: 30),
          ],
          _Reveal(
            delay: const Duration(milliseconds: 130),
            child: DestinationCards(onVibeTap: _openExploreForVibe),
          ),
          const SizedBox(height: 32),
          _Reveal(
            delay: const Duration(milliseconds: 180),
            child: TrendingDestinations(
              destinations: state.destinations,
              counts: state.destinationCounts,
              onDestinationTap: _openExploreForCity,
            ),
          ),
          const SizedBox(height: 32),
          if (state.trendingProperties.isNotEmpty) ...[
            _Reveal(
              delay: const Duration(milliseconds: 230),
              child: FeaturedStays(
                properties: state.trendingProperties,
                onSeeAll: () => _openExplore(),
                onPropertyTap: (property) =>
                    context.push(AppRoutes.propertyDetailOf(property.id)),
              ),
            ),
            const SizedBox(height: 30),
          ],
          if (state.showBecomeHostBanner) ...[
            HostBanner(onTap: () => context.push(AppRoutes.hostRegister)),
            const SizedBox(height: 32),
          ],
          if (state.topRatedProperties.isNotEmpty) ...[
            FeaturedStays(
              title: 'Top Rated',
              properties: state.topRatedProperties,
              onSeeAll: () => _openExplore(),
              onPropertyTap: (property) =>
                  context.push(AppRoutes.propertyDetailOf(property.id)),
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Search bar
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openExplore,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4F5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8E0E3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(0xFFE8507A),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where do you want to stay?',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Destination, dates and guests',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF7C7480),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF1A1A2E),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openExplore({String? city, String? vibe}) {
    final uri = Uri(
      path: AppRoutes.explore,
      queryParameters: {
        if (city != null) 'city': city,
        if (vibe != null) 'vibe': vibe,
      },
    );
    context.go(uri.toString());
  }

  void _openExploreForCity(String city) => _openExplore(city: city);

  void _openExploreForVibe(String vibe) => _openExplore(vibe: vibe);

  // ═══════════════════════════════════════════════════════════════════════════
  // Shimmer / loading placeholder
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Search bar placeholder
          _shimmerBox(height: 48, radius: 50),
          const SizedBox(height: 20),

          // Filter chips placeholder
          Row(
            children: List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _shimmerBox(height: 36, width: 80, radius: 50),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hero placeholder
          _shimmerBox(height: 200, radius: 20),
          const SizedBox(height: 20),

          // Cards placeholder
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _shimmerBox(height: 110, radius: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 12,
  }) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Error state
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.read<HomeCubit>().refresh(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8507A),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
