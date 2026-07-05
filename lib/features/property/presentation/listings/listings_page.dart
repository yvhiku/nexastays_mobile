import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../navigation/app_routes.dart';

import '../../../search/domain/entities/search_filter.dart';
import '../../domain/entities/property.dart';
import 'bloc/listings_event.dart';
import 'bloc/listings_state.dart';
import 'bloc/listings_bloc.dart';
import 'property_card.dart';

/// The "All Stays" listings page with sort, pagination, shimmer loading,
/// empty/error states, and save toggle — driven by [ListingsBloc].
class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ListingsBloc>().add(const ListingsLoadRequested());
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ListingsBloc>().state;
      if (state is ListingsLoaded && state.hasMore) {
        context.read<ListingsBloc>().add(const ListingsLoadMoreRequested());
      }
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: BlocConsumer<ListingsBloc, ListingsState>(
                listener: _blocListener,
                builder: (context, state) {
                  return switch (state) {
                    ListingsInitial()    => _buildShimmerList(),
                    ListingsLoading()    => _buildShimmerList(),
                    ListingsRefreshing() => _buildRefreshableList(state.currentProperties),
                    ListingsLoaded()     => _buildLoadedList(state),
                    ListingsLoadingMore() => _buildRefreshableList(state.currentProperties, loadingMore: true),
                    ListingsEmpty()       => _buildEmptyState(state.filter),
                    ListingsError()       => _buildErrorState(state),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _blocListener(BuildContext context, ListingsState state) {
    if (state is ListingsError && state.cachedProperties.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // TOP BAR
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 12),
          // Title + count
          Expanded(
            child: BlocBuilder<ListingsBloc, ListingsState>(
              builder: (context, state) {
                int count = 0;
                if (state is ListingsLoaded) count = state.totalCount;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Stays',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    if (count > 0)
                      Text(
                        '$count result${count == 1 ? '' : 's'}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Sort button
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, state) {
        SortOrder currentSort = SortOrder.bestMatch;
        if (state is ListingsLoaded) currentSort = state.sortOrder;

        return GestureDetector(
          onTap: () => _showSortSheet(currentSort),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sortLabel(currentSort),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortSheet(SortOrder current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sort by',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                ...SortOrder.values.map(
                  (order) => _sortOptionTile(order, current),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortOptionTile(SortOrder order, SortOrder current) {
    final isSelected = order == current;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        context
            .read<ListingsBloc>()
            .add(ListingsSortChanged(sortOrder: order));
        Navigator.pop(context);
      },
      title: Text(
        _sortLabel(order),
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? const Color(0xFFE8507A)
              : const Color(0xFF1A1A2E),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, size: 20, color: Color(0xFFE8507A))
          : null,
    );
  }

  String _sortLabel(SortOrder order) {
    return switch (order) {
      SortOrder.bestMatch  => 'Best match',
      SortOrder.priceLow   => 'Price: Low → High',
      SortOrder.priceHigh  => 'Price: High → Low',
      SortOrder.newest     => 'Newest',
    };
  }

  // ═════════════════════════════════════════════════════════════════════════
  // LOADED LIST
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildLoadedList(ListingsLoaded state) {
    return RefreshIndicator(
      color: const Color(0xFFE8507A),
      onRefresh: () async {
        context.read<ListingsBloc>().add(const ListingsRefreshRequested());
        // Wait for state change
        await context.read<ListingsBloc>().stream.firstWhere(
              (s) => s is! ListingsRefreshing,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.properties.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.properties.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE8507A),
                  strokeWidth: 2.5,
                ),
              ),
            );
          }
          final property = state.properties[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PropertyListCard(
              property: property,
              isSaved: state.savedPropertyIds.contains(property.id),
              onSaveToggle: () {
                context.read<ListingsBloc>().add(ListingsSaveToggled(
                      propertyId: property.id,
                      property: property,
                      currentlySaved:
                          state.savedPropertyIds.contains(property.id),
                    ));
              },
              onTap: () => context.push(AppRoutes.propertyDetailOf(property.id)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRefreshableList(List<Property> properties,
      {bool loadingMore = false}) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: properties.length + (loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= properties.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE8507A),
                strokeWidth: 2.5,
              ),
            ),
          );
        }
        final property = properties[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PropertyListCard(
            property: property,
            onTap: () => context.push(AppRoutes.propertyDetailOf(property.id)),
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SHIMMER
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ShimmerCard(),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // EMPTY
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(SearchFilter? filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏠', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No stays found',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different filters or another city',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.read<ListingsBloc>().add(
                    const ListingsFilterChanged(filter: SearchFilter()),
                  ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0F5),
                foregroundColor: const Color(0xFFE8507A),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'Clear filters',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // ERROR
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildErrorState(ListingsError state) {
    if (state.cachedProperties.isNotEmpty) {
      return Column(
        children: [
          _ErrorBanner(message: state.message),
          Expanded(
            child: _buildRefreshableList(state.cachedProperties),
          ),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off,
                size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context
                  .read<ListingsBloc>()
                  .add(const ListingsLoadRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8507A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Private widgets
// ═════════════════════════════════════════════════════════════════════════════

class _ErrorBanner extends StatefulWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing cached results — check connection',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _visible = false),
            child: const Icon(Icons.close,
                size: 16, color: Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image skeleton
          Container(
            width: 110,
            height: 130,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          // Text skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 140,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
