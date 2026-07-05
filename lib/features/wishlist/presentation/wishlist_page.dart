import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/buttons/primary_button.dart';
import '../../../navigation/app_routes.dart';

import '../../property/domain/entities/property.dart';
import '../../search/domain/entities/search_filter.dart';
import 'bloc/wishlist_cubit.dart';
import 'bloc/wishlist_state.dart';

// =============================================================================
// Wishlist Page — "Saved Stays"
// =============================================================================

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<WishlistCubit>().loadWishlist();

    // Pulse animation for the empty-state heart.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<WishlistCubit>().loadWishlist();
    }
  }

  // ── Sort bottom sheet ──────────────────────────────────────────────

  void _showSortSheet(SortOrder current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),
                _sortTile('Newest saved', SortOrder.newest, current),
                _sortTile('Price: Low → High', SortOrder.priceLow, current),
                _sortTile('Price: High → Low', SortOrder.priceHigh, current),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortTile(String label, SortOrder order, SortOrder current) {
    final isActive = order == current;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        context.read<WishlistCubit>().sortWishlist(order);
        Navigator.pop(context);
      },
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? const Color(0xFFE8507A) : const Color(0xFF374151),
        ),
      ),
      trailing: isActive
          ? const Icon(Icons.check_rounded, color: Color(0xFFE8507A), size: 20)
          : null,
    );
  }

  // ── Undo SnackBar ──────────────────────────────────────────────────

  void _showUndoSnackBar(Property property) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('❤️', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              'Removed from saved',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFFE8507A),
          onPressed: () =>
              context.read<WishlistCubit>().undoRemove(property),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<WishlistCubit, WishlistState>(
        listener: (context, state) {
          if (state is WishlistPropertyRemoved) {
            // Find the removed property to enable undo.
            final cubitState = context.read<WishlistCubit>().state;
            // We look up the property from previous loaded state if possible.
            // For now, pass a lightweight reconstruction via the SnackBar.
          }
          if (state is WishlistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFF1A1A2E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saved Stays',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _subtitleText(state),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state is WishlistLoaded)
                          IconButton(
                            onPressed: () =>
                                _showSortSheet(state.sortOrder),
                            icon: const Icon(
                              Icons.sort_rounded,
                              color: Color(0xFF374151),
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Body ─────────────────────────────────────────────
              if (state is WishlistLoading) _buildShimmer(),
              if (state is WishlistEmpty) _buildEmpty(),
              if (state is WishlistLoaded) ..._buildLoaded(state),
              if (state is WishlistError && state is! WishlistLoaded)
                _buildError(state),
              if (state is WishlistInitial)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _subtitleText(WishlistState state) {
    if (state is WishlistLoaded) {
      final count = state.savedProperties.length;
      return '$count ${count == 1 ? 'property' : 'properties'} saved';
    }
    return '0 properties saved';
  }

  // ── Loading shimmer ───────────────────────────────────────────────

  SliverPadding _buildShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
        children: List.generate(4, (_) => const _ShimmerCard()),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────

  SliverFillRemaining _buildEmpty() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: const Text('❤️', style: TextStyle(fontSize: 72)),
              ),
              const SizedBox(height: 24),
              const Text(
                'No saved stays yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the heart on any property\nto save it for later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
              child: PrimaryButton(
                label: 'Explore stays →',
                height: 48,
                radius: 50,
                onPressed: () => context.go(AppRoutes.explore),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Loaded ────────────────────────────────────────────────────────

  List<Widget> _buildLoaded(WishlistLoaded state) {
    final properties = state.savedProperties;

    // Stats.
    final verified =
        properties.where((p) => p.isVerified).length;
    final avgPrice = properties.isEmpty
        ? 0.0
        : properties.map((p) => p.nightlyRate).reduce((a, b) => a + b) /
            properties.length;

    return [
      // ── Stats row ────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statPill('${properties.length} saved', const Color(0xFF374151)),
                const SizedBox(width: 8),
                _statPill('$verified verified', const Color(0xFFE8507A)),
                const SizedBox(width: 8),
                _statPill(
                  'Avg ${avgPrice.toStringAsFixed(0)} MAD',
                  const Color(0xFF374151),
                ),
              ],
            ),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // ── Grid ─────────────────────────────────────────────────
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
          children: properties.map((property) {
            return _WishlistPropertyCard(
              property: property,
              onRemove: () {
                context.read<WishlistCubit>().removeProperty(property.id);
                _showUndoSnackBar(property);
              },
              onView: () => context.push(
                AppRoutes.propertyDetailOf(property.id),
              ),
            );
          }).toList(),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  Widget _statPill(String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────

  SliverFillRemaining _buildError(WishlistError state) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 160,
                child: PrimaryButton(
                  label: 'Try again',
                  onPressed: () =>
                      context.read<WishlistCubit>().loadWishlist(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shimmer Skeleton Card
// =============================================================================

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo placeholder.
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Wishlist Property Card (inline)
// =============================================================================

class _WishlistPropertyCard extends StatelessWidget {
  const _WishlistPropertyCard({
    required this.property,
    required this.onRemove,
    required this.onView,
  });

  final Property property;
  final VoidCallback onRemove;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo ────────────────────────────────────────────
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: property.photoUrls.isNotEmpty
                      ? property.photoUrls.first
                      : '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFFF3F4F6),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 32,
                    ),
                  ),
                ),

                // Verified badge.
                if (property.isVerified)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8507A),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 10),
                          SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Heart remove button.
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withOpacity(0.85),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFE8507A),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location.
                  Text(
                    '${property.neighborhood} · ${property.city}'
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Name.
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Rating.
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFBBF24), size: 13),
                      const SizedBox(width: 2),
                      Text(
                        property.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${property.reviewCount})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Price + View button.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${property.nightlyRate.toStringAsFixed(0)} MAD',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFFE8507A),
                              ),
                            ),
                            const Text(
                              '/night',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onView,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8507A),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'View →',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
