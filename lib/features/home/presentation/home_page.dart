import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/components/nexa_stays_wordmark.dart';
import '../../../navigation/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profile/presentation/widgets/profile_photo_avatar.dart';
import 'bloc/home_cubit.dart';
import 'bloc/home_state.dart';
import '../domain/entities/property.dart';
import 'widgets/hero_section.dart';
import 'widgets/featured_stays.dart';
import 'widgets/host_banner.dart';
import '../../search/presentation/widgets/filter_chip.dart';

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
  String _activeFilter = 'Verified';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filter chip data ────────────────────────────────────────────────────
  static const List<_FilterItem> _filters = [
    _FilterItem(emoji: '✅', label: 'Verified', tag: 'verified'),
    _FilterItem(emoji: '⚡', label: 'Instant', tag: 'instant'),
    _FilterItem(emoji: '👨‍👩‍👧', label: 'Family', tag: 'family'),
    _FilterItem(emoji: '💑', label: 'Couples', tag: 'couples'),
  ];

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

          // 1. Search bar
          _buildSearchBar(),
          const SizedBox(height: 20),

          // 2. Filter chips
          _buildFilterChips(),
          const SizedBox(height: 20),

          // 3. Featured listing hero
          if (state.featuredProperties.isNotEmpty) ...[
            HeroSection(property: state.featuredProperties.first),
            const SizedBox(height: 20),
          ],

          // 4. Today's Drops (horizontal scroll)
          if (state.trendingProperties.isNotEmpty) ...[
            Builder(
              builder: (context) {
                List<Property> filteredList = state.trendingProperties;

                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  filteredList = filteredList.where((p) {
                    return p.city.toLowerCase().contains(query) ||
                        p.title.toLowerCase().contains(query);
                  }).toList();
                }

                if (_activeFilter == 'instant') {
                  // Simulate "Instant book"
                  filteredList = filteredList
                      .where((p) => p.id.hashCode % 2 == 0)
                      .toList();
                } else if (_activeFilter == 'family') {
                  filteredList =
                      filteredList.where((p) => p.maxGuests >= 4).toList();
                } else if (_activeFilter == 'couples') {
                  filteredList =
                      filteredList.where((p) => p.maxGuests <= 2).toList();
                }

                // Fallback to original list if filter yields no results to prevent empty states, but not on active text search
                if (filteredList.isEmpty && _searchController.text.isEmpty) {
                  filteredList = state.trendingProperties;
                }

                if (filteredList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No stays found for your search.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  );
                }

                return FeaturedStays(
                  properties: filteredList,
                  onSeeAll: () => context.push(AppRoutes.listings),
                  onPropertyTap: (property) =>
                      context.push(AppRoutes.propertyDetailOf(property.id)),
                );
              },
            ),
          ],
          const SizedBox(height: 28),

          // 5. Host banner — hidden for approved / pending hosts (matches web)
          if (state.showBecomeHostBanner) ...[
            HostBanner(onTap: () => context.push(AppRoutes.hostRegister)),
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
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 12, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF1A1A2E),
              ),
              cursorColor: const Color(0xFFE8507A),
              decoration: InputDecoration(
                hintText: 'Marrakech, Casablanca...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.close, color: Color(0xFF9CA3AF), size: 18),
              ),
            ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.tune,
              color: Color(0xFFE8507A),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Filter chips
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFilterChips() {
    return SizedBox(
      height: NexaFilterChip.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          if (index == _filters.length) {
            return Container(
              width: NexaFilterChip.chipHeight,
              height: NexaFilterChip.chipHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.center,
              child: const Text('🐾', style: TextStyle(fontSize: 16, height: 1)),
            );
          }

          final filter = _filters[index];
          final isActive = _activeFilter == filter.tag ||
              (_activeFilter == 'Verified' && filter.tag == 'verified');

          return NexaFilterChip(
            emoji: filter.emoji,
            label: filter.label,
            isActive: isActive,
            onTap: () => setState(() => _activeFilter = filter.tag),
          );
        },
      ),
    );
  }

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

// ═════════════════════════════════════════════════════════════════════════════
// Filter item data class
// ═════════════════════════════════════════════════════════════════════════════

class _FilterItem {
  final String emoji;
  final String label;
  final String tag;

  const _FilterItem({
    required this.emoji,
    required this.label,
    required this.tag,
  });
}
