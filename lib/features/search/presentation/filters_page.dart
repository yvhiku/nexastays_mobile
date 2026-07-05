import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../domain/entities/search_filter.dart';
import 'bloc/filters_cubit.dart';
import 'bloc/search_bloc.dart';
import 'bloc/search_event.dart';
import 'bloc/search_state.dart';
import 'widgets/filter_chip.dart';
import 'widgets/host_preference_filters.dart';
import '../../../../design_system/components/buttons/pill_button.dart';

/// Full-screen scrollable filter bottom sheet for the search feature.
///
/// Wraps itself in a [FiltersCubit] seeded with the current search filter.
/// As the user interacts with the sheet, [FiltersCubit] updates local state.
/// When they tap "Show X stays", the final filter is dispatched to [SearchBloc].
class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key, required this.initialFilter});

  final SearchFilter initialFilter;

  /// Shows the filters page as a modal bottom sheet.
  static Future<void> show(BuildContext context, SearchFilter current) {
    // We capture the existing SearchBloc so we can provide it to the sheet route
    final searchBloc = context.read<SearchBloc>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: searchBloc),
            BlocProvider(
              create: (_) => FiltersCubit.from(current),
            ),
          ],
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return FiltersBottomSheetView(
                initialFilter: current,
                scrollController: scrollController,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using static show() is preferred.
    return const SizedBox.shrink();
  }
}

class FiltersBottomSheetView extends StatelessWidget {
  const FiltersBottomSheetView({
    super.key,
    required this.initialFilter,
    required this.scrollController,
  });

  final SearchFilter initialFilter;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocBuilder<FiltersCubit, SearchFilter>(
        builder: (context, filterState) {
          return Column(
            children: [
              // ── Header (Sticky) ─────────────────────────────────────────
              _buildHeader(context),

              // ── Scrollable Body ─────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    // 1. WHERE
                    _buildSectionTitle('Where are you going?'),
                    const SizedBox(height: 16),
                    _buildCityGrid(context, filterState),
                    _buildDivider(),

                    // 2. WHEN
                    _buildSectionTitle('Check-in / Check-out'),
                    const SizedBox(height: 16),
                    _buildDateSelectors(context, filterState),
                    _buildDivider(),

                    // 3. GUESTS
                    _buildSectionTitle('Guests'),
                    const SizedBox(height: 16),
                    _buildGuestsSelector(context, filterState),
                    _buildDivider(),

                    // 4. VIBE
                    _buildSectionTitle('Choose your vibe'),
                    const SizedBox(height: 16),
                    _buildVibeChips(context, filterState),
                    _buildDivider(),

                    // 5 & 6. GUEST TYPE & PRICE RANGE & BEDS
                    HostPreferenceFilters(
                      currentFilter: filterState,
                      cubit: context.read<FiltersCubit>(),
                    ),
                    _buildDivider(),

                    // 7. FEATURES
                    _buildFeaturesToggles(context, filterState),
                  ],
                ),
              ),

              // ── Footer (Sticky) ─────────────────────────────────────────
              _buildFooter(context, filterState),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Components
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () => context.read<FiltersCubit>().resetFilters(),
                child: Text(
                  'Reset all',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE8507A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, SearchFilter filterState) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16).copyWith(
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, searchState) {
          // Provide an optimistic count if search is active
          String countText = 'Show stays';
          if (searchState is SearchResults) {
            countText = 'Show ${searchState.totalCount} stays';
          }

          return NexaPillButton(
            label: countText,
            height: 52,
            onTap: () {
              context
                  .read<SearchBloc>()
                  .add(SearchInitiated(filter: filterState));
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  // 1. Where
  Widget _buildCityGrid(BuildContext context, SearchFilter filter) {
    const cities = [
      'Marrakech',
      'Casablanca',
      'Rabat',
      'Tangier',
      'Agadir',
      'Fez'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (_, index) {
        final city = cities[index];
        final isSelected = filter.city == city;

        return GestureDetector(
          onTap: () =>
              context.read<FiltersCubit>().setCity(isSelected ? '' : city),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE8507A)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              city,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFE8507A)
                    : const Color(0xFF1A1A2E),
              ),
            ),
          ),
        );
      },
    );
  }

  // 2. When
  Widget _buildDateSelectors(BuildContext context, SearchFilter filter) {
    final dateFormat = DateFormat('MMM d, yyyy');

    Future<void> pickDates() async {
      final now = DateTime.now();
      final range = await showDateRangePicker(
        context: context,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
        initialDateRange: filter.checkIn != null && filter.checkOut != null
            ? DateTimeRange(start: filter.checkIn!, end: filter.checkOut!)
            : null,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFE8507A),
                onPrimary: Colors.white,
                onSurface: Color(0xFF1A1A2E),
              ),
            ),
            child: child!,
          );
        },
      );

      if (range != null && context.mounted) {
        context.read<FiltersCubit>().setDates(range.start, range.end);
      }
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: pickDates,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-in',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filter.checkIn != null
                        ? dateFormat.format(filter.checkIn!)
                        : 'Add dates',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: filter.checkIn != null
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: pickDates,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-out',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filter.checkOut != null
                        ? dateFormat.format(filter.checkOut!)
                        : 'Add dates',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: filter.checkOut != null
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3. Guests
  Widget _buildGuestsSelector(BuildContext context, SearchFilter filter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total guests',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        Row(
          children: [
            _buildStepperButton(
              icon: Icons.remove,
              enabled: filter.guestCount > 1,
              onTap: () {
                if (filter.guestCount > 1) {
                  context.read<FiltersCubit>().setGuests(filter.guestCount - 1);
                }
              },
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${filter.guestCount}',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            _buildStepperButton(
              icon: Icons.add,
              enabled: filter.guestCount < 16,
              onTap: () {
                if (filter.guestCount < 16) {
                  context.read<FiltersCubit>().setGuests(filter.guestCount + 1);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF1A1A2E) : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }

  // 4. Vibe
  Widget _buildVibeChips(BuildContext context, SearchFilter filter) {
    const vibes = ['rooftop', 'riad', 'ocean', 'desert', 'city'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vibes.map((v) {
          final label = v[0].toUpperCase() + v.substring(1);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: NexaFilterChip(
              label: label,
              isActive: filter.vibes.contains(v),
              onTap: () => context.read<FiltersCubit>().toggleVibe(v),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 7. Features
  Widget _buildFeaturesToggles(BuildContext context, SearchFilter filter) {
    return Column(
      children: [
        SwitchListTile(
          value: filter.verifiedOnly,
          onChanged: (_) => context.read<FiltersCubit>().toggleVerifiedOnly(),
          activeColor: const Color(0xFFE8507A),
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Verified only',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          subtitle: Text(
            'Show only properties with verified walkthrough videos',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: filter.instantBookOnly,
          onChanged: (_) => context.read<FiltersCubit>().toggleInstantOnly(),
          activeColor: const Color(0xFFE8507A),
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Instant booking',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          subtitle: Text(
            'Properties that don\'t require host approval',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}
