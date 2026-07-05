import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/app_routes.dart';
import '../../property/domain/entities/property.dart' as property_domain;
import '../../property/domain/entities/host_preferences.dart'
    as host_prefs_domain;
import '../../home/presentation/widgets/destination_cards.dart';
import '../../property/presentation/listings/property_card.dart';
import '../domain/entities/search_filter.dart';
import 'bloc/search_bloc.dart';
import 'bloc/search_event.dart';
import 'bloc/search_state.dart';
import 'widgets/filter_chip.dart';
import 'widgets/search_bar.dart';
import '../../../../design_system/components/buttons/pill_button.dart';
import 'filters_page.dart';

/// The main Explore / Search page for NexaStays.
///
/// Displays active search criteria via a [NexaSearchBar], horizontal
/// filter chips, and the current list of property results.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _searchStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_searchStarted) {
      _searchStarted = true;
      context.read<SearchBloc>().add(
            const SearchInitiated(filter: SearchFilter()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _SearchPageView();
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  // ── Handlers ────────────────────────────────────────────────────────────

  void _onSearchTap(BuildContext context, SearchFilter currentFilter) {
    FiltersPage.show(context, currentFilter);
  }

  void _onClearSearch(BuildContext context) {
    context.read<SearchBloc>().add(const SearchCleared());
  }

  void _toggleFilter(BuildContext context, SearchFilter currentFilter,
      SearchFilter Function(SearchFilter) updater) {
    final newFilter = updater(currentFilter);
    context.read<SearchBloc>().add(SearchFilterUpdated(filter: newFilter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            final filter = _extractFilter(state);
            final summary = filter.searchSummary;
            final isSearching = filter.hasActiveFilters;

            return CustomScrollView(
              slivers: [
                // ── Top Bar & Search ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(state),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: NexaSearchBar(
                          currentSummary: isSearching ? summary : null,
                          onTap: () => _onSearchTap(context, filter),
                          onClear: isSearching
                              ? () => _onClearSearch(context)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFilterChips(context, filter),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Vibe Row ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DestinationCards(
                      onVibeTap: (tag) => _toggleFilter(
                        context,
                        filter,
                        (f) {
                          final updated = List<String>.from(f.vibes);
                          if (updated.contains(tag)) {
                            updated.remove(tag);
                          } else {
                            updated.add(tag);
                          }
                          return f.copyWith(vibes: updated);
                        },
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Results / Content ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildContent(context, state),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Builders
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTopBar(SearchState state) {
    int count = 0;
    if (state is SearchResults) {
      count = state.totalCount;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stays in Morocco',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          if (state is SearchResults)
            Text(
              '$count verified stay${count == 1 ? '' : 's'} found',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, SearchFilter filter) {
    return SizedBox(
      height: NexaFilterChip.chipHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          NexaFilterChip(
            label: 'Verified',
            emoji: '✓',
            isActive: filter.verifiedOnly,
            onTap: () => _toggleFilter(context, filter,
                (f) => f.copyWith(verifiedOnly: !f.verifiedOnly)),
          ),
          const SizedBox(width: 8),
          NexaFilterChip(
            label: 'Instant',
            emoji: '⚡',
            isActive: filter.instantBookOnly,
            onTap: () => _toggleFilter(context, filter,
                (f) => f.copyWith(instantBookOnly: !f.instantBookOnly)),
          ),
          const SizedBox(width: 8),
          NexaFilterChip(
            label: 'Couples',
            emoji: '💑',
            isActive: filter.guestType == 'couples',
            onTap: () => _toggleFilter(
                context,
                filter,
                (f) => f.copyWith(
                    guestType: f.guestType == 'couples' ? null : 'couples')),
          ),
          const SizedBox(width: 8),
          NexaFilterChip(
            label: 'Family',
            emoji: '👨‍👩‍👧',
            isActive: filter.guestType == 'family',
            onTap: () => _toggleFilter(
                context,
                filter,
                (f) => f.copyWith(
                    guestType: f.guestType == 'family' ? null : 'family')),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchState state) {
    if (state is SearchInitial || state is SearchLoading) {
      return _buildShimmer();
    }
    if (state is SearchEmpty) {
      return _buildEmptyState(context);
    }
    if (state is SearchError) {
      return _buildErrorState(context, state.message, _extractFilter(state));
    }
    if (state is SearchResults) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Drops 🔥',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.listings),
                child: Text(
                  'See all',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE8507A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.properties.length,
            itemBuilder: (_, index) {
              final homeProp = state.properties[index];
              // Map home Property to property Domain Property for the List Card
              final property = property_domain.Property(
                id: homeProp.id,
                hostId: homeProp.hostId,
                name: homeProp.title,
                description: homeProp.description,
                city: homeProp.city,
                neighborhood:
                    homeProp.address, // Mapping address to neighborhood
                exactAddress: homeProp.address,
                propertyType: homeProp.propertyType,
                hostType: 'superhost',
                beds: homeProp.bedrooms,
                bathrooms: homeProp.bathrooms,
                maxGuests: homeProp.maxGuests,
                nightlyRate: homeProp.pricePerNight,
                photoUrls: homeProp.images.isNotEmpty
                    ? homeProp.images
                    : [homeProp.imageUrl],
                amenities: homeProp.amenities,
                rules: const host_prefs_domain.HostPreferences(
                  checkInFrom: '15:00',
                  checkOutBefore: '11:00',
                ),
                rating: homeProp.rating,
                reviewCount: homeProp.reviewCount,
                isVerified: homeProp.isVerified,
                isInstantBook: homeProp.isInstantBook,
                vibeTags: const [],
                checkInContact: '',
                checkInInstructions: '',
                checkInMethod: '',
                isTrending: homeProp.isTrending,
                listedAt: homeProp.createdAt,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PropertyListCard(
                  property: property,
                  buttonText: 'View Stay',
                  onTap: () =>
                      context.push(AppRoutes.propertyDetailOf(property.id)),
                ),
              );
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            'No stays found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different filters',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          NexaPillButton(
            label: 'Clear all filters',
            height: 44,
            expandWidth: false,
            gradient: null,
            backgroundColor: const Color(0xFFFFF0F5),
            textColor: const Color(0xFFE8507A),
            onTap: () => _onClearSearch(context),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    SearchFilter filter,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF9CA3AF)),
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
            NexaPillButton(
              label: 'Try again',
              height: 44,
              expandWidth: false,
              gradient: null,
              backgroundColor: const Color(0xFFE8507A),
              textColor: Colors.white,
              onTap: () => context.read<SearchBloc>().add(
                    SearchInitiated(filter: filter),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  SearchFilter _extractFilter(SearchState state) {
    if (state is SearchLoading) return state.filter;
    if (state is SearchResults) return state.activeFilter;
    if (state is SearchEmpty) return state.filter;
    return const SearchFilter();
  }
}
