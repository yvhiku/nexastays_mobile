import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../navigation/app_routes.dart';
import '../../home/domain/entities/property.dart' as home;
import '../../property/presentation/widgets/stay_card.dart';
import '../domain/entities/search_filter.dart';
import 'bloc/search_bloc.dart';
import 'bloc/search_event.dart';
import 'bloc/search_state.dart';
import 'filters_page.dart';
import 'widgets/explore_map.dart';
import 'widgets/search_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _searchStarted = false;
  String? _lastDeepLink;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final query = GoRouterState.of(context).uri.queryParameters;
    final signature = Uri(queryParameters: query).query;
    if (!_searchStarted || (query.isNotEmpty && signature != _lastDeepLink)) {
      _searchStarted = true;
      _lastDeepLink = signature;
      context.read<SearchBloc>().add(
            SearchInitiated(
              filter: SearchFilter(
                city: query['city'],
                vibes: query['vibe'] == null ? const [] : [query['vibe']!],
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) => const _SearchPageView();
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  bool _showMap = false;

  void _toggleFilter(
    BuildContext context,
    SearchFilter filter,
    SearchFilter Function(SearchFilter) updater,
  ) {
    context
        .read<SearchBloc>()
        .add(SearchFilterUpdated(filter: updater(filter)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            final filter = _extractFilter(state);
            return Column(
              children: [
                _ExploreHeader(
                  state: state,
                  filter: filter,
                  showMap: _showMap,
                  onSearchTap: () => FiltersPage.show(context, filter),
                  onClear: filter.hasActiveFilters
                      ? () =>
                          context.read<SearchBloc>().add(const SearchCleared())
                      : null,
                  onViewChanged: (showMap) =>
                      setState(() => _showMap = showMap),
                  onToggle: (updater) =>
                      _toggleFilter(context, filter, updater),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    child: _showMap
                        ? _buildMap(state)
                        : _buildList(context, state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, SearchState state) {
    if (state is SearchInitial || state is SearchLoading) {
      return const _ExploreLoading(key: ValueKey('loading'));
    }
    if (state is SearchEmpty) {
      return _ExploreEmpty(
        key: const ValueKey('empty'),
        onClear: () => context.read<SearchBloc>().add(const SearchCleared()),
      );
    }
    if (state is SearchError) {
      return _ExploreError(
        key: const ValueKey('error'),
        message: state.message,
        onRetry: () => context.read<SearchBloc>().add(
              SearchInitiated(filter: _extractFilter(state)),
            ),
      );
    }
    if (state is SearchResults) {
      return ListView.separated(
        key: const ValueKey('list'),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        itemCount: state.properties.length,
        separatorBuilder: (_, __) => const SizedBox(height: 28),
        itemBuilder: (context, index) {
          final property = state.properties[index];
          return StayCard(
            stay: StayCardData.fromHomeProperty(property),
            onTap: () => context.push(AppRoutes.propertyDetailOf(property.id)),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMap(SearchState state) {
    final List<home.Property> properties =
        state is SearchResults ? state.properties : const [];
    return ExploreMap(
      key: const ValueKey('map'),
      properties: properties,
    );
  }

  SearchFilter _extractFilter(SearchState state) {
    if (state is SearchLoading) return state.filter;
    if (state is SearchResults) return state.activeFilter;
    if (state is SearchEmpty) return state.filter;
    return const SearchFilter();
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({
    required this.state,
    required this.filter,
    required this.showMap,
    required this.onSearchTap,
    required this.onClear,
    required this.onViewChanged,
    required this.onToggle,
  });

  final SearchState state;
  final SearchFilter filter;
  final bool showMap;
  final VoidCallback onSearchTap;
  final VoidCallback? onClear;
  final ValueChanged<bool> onViewChanged;
  final ValueChanged<SearchFilter Function(SearchFilter)> onToggle;

  @override
  Widget build(BuildContext context) {
    final count =
        state is SearchResults ? (state as SearchResults).totalCount : 0;
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Explore Morocco',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                if (state is SearchResults)
                  Text(
                    '$count ${count == 1 ? 'stay' : 'stays'}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            NexaSearchBar(
              currentSummary:
                  filter.hasActiveFilters ? filter.searchSummary : null,
              onTap: onSearchTap,
              onClear: onClear,
            ),
            const SizedBox(height: 10),
            _CriteriaRow(filter: filter, onTap: onSearchTap),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _QuickFilter(
                    icon: Icons.verified_rounded,
                    label: 'Verified',
                    selected: filter.verifiedOnly,
                    onTap: () => onToggle(
                      (f) => f.copyWith(verifiedOnly: !f.verifiedOnly),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickFilter(
                    icon: Icons.bolt_rounded,
                    label: 'Instant',
                    selected: filter.instantBookOnly,
                    onTap: () => onToggle(
                      (f) => f.copyWith(instantBookOnly: !f.instantBookOnly),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickFilter(
                    icon: Icons.beach_access_rounded,
                    label: 'Beach',
                    selected: filter.vibes.contains('ocean'),
                    onTap: () => onToggle((f) {
                      final vibes = List<String>.from(f.vibes);
                      vibes.contains('ocean')
                          ? vibes.remove('ocean')
                          : vibes.add('ocean');
                      return f.copyWith(vibes: vibes);
                    }),
                  ),
                  const SizedBox(width: 8),
                  _QuickFilter(
                    icon: Icons.home_work_outlined,
                    label: 'Entire place',
                    selected: filter.guestType == 'entire_place',
                    onTap: () => onToggle(
                      (f) => f.copyWith(
                        guestType: f.guestType == 'entire_place'
                            ? null
                            : 'entire_place',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: _ViewToggle(
                showMap: showMap,
                onChanged: onViewChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  const _CriteriaRow({required this.filter, required this.onTap});

  final SearchFilter filter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dates = filter.checkIn == null
        ? 'Add dates'
        : DateFormat('MMM d').format(filter.checkIn!);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _Criterion(
              icon: Icons.place_outlined,
              label: filter.city ?? 'Where?',
            ),
            _divider(),
            _Criterion(icon: Icons.calendar_today_outlined, label: dates),
            _divider(),
            _Criterion(
              icon: Icons.people_outline_rounded,
              label:
                  '${filter.guestCount} guest${filter.guestCount == 1 ? '' : 's'}',
            ),
            _divider(),
            const _Criterion(icon: Icons.tune_rounded, label: 'Filters'),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const SizedBox(
        height: 25,
        child: VerticalDivider(width: 1, color: Color(0xFFE0D8DB)),
      );
}

class _Criterion extends StatelessWidget {
  const _Criterion({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
        child: Column(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF7C5260)),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFilter extends StatelessWidget {
  const _QuickFilter({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 16),
      label: Text(label),
      showCheckmark: false,
      selectedColor: const Color(0xFFFFE5ED),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
      ),
      labelStyle: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? const Color(0xFFB72551) : const Color(0xFF374151),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.showMap, required this.onChanged});

  final bool showMap;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECEE),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('LIST', Icons.view_agenda_outlined, !showMap, () {
            onChanged(false);
          }),
          _segment('MAP', Icons.map_outlined, showMap, () {
            onChanged(true);
          }),
        ],
      ),
    );
  }

  Widget _segment(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF1A1A2E)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreLoading extends StatelessWidget {
  const _ExploreLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (_, __) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _ExploreEmpty extends StatelessWidget {
  const _ExploreEmpty({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.travel_explore_rounded,
            size: 52, color: Color(0xFFE8507A)),
        const SizedBox(height: 18),
        Text(
          'No stays match these filters.',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Try removing Instant Book, broadening your dates or searching a nearby city.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            height: 1.5,
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear filters'),
          ),
        ),
      ],
    );
  }
}

class _ExploreError extends StatelessWidget {
  const _ExploreError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
