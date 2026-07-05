import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/host_dashboard_cubit.dart';
import 'bloc/host_dashboard_state.dart';
import 'widgets/listing_status_badge.dart';
import '../../home/domain/entities/property.dart';
import '../../../navigation/app_routes.dart';

class HostDashboardPage extends StatefulWidget {
  const HostDashboardPage({super.key});

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<HostDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<HostDashboardCubit, HostDashboardState>(
        listener: (context, state) {
          if (state is HostDashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.dmSans()),
                backgroundColor: const Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HostDashboardInitial || state is HostDashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            );
          }

          if (state is HostDashboardError) {
            return _buildError(context, state.message);
          }

          if (state is HostDashboardLoaded) {
            return _buildLoaded(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Error State
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: Color(0xFFDC2626), size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Dashboard Unavailable',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.read<HostDashboardCubit>().refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8507A),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFE8507A).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Loaded State Content
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLoaded(BuildContext context, HostDashboardLoaded state) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        _buildSliverAppBar(context, state),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOnboardingBanner(context, state),
                const SizedBox(height: 16),
                _buildEarningsCard(state),
                const SizedBox(height: 32),
                _buildQuickActions(state),
                const SizedBox(height: 40),
                _buildAnalyticsSection(state),
                const SizedBox(height: 40),
                _buildListingsHeader(context),
                const SizedBox(height: 20),
                if (state.listings.isEmpty)
                  _buildEmptyListings()
                else
                  ...state.listings.map((p) => _buildListingCard(context, p)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingBanner(BuildContext context, HostDashboardLoaded state) {
    final me = state.hostMe;
    if (me.isApproved && me.canCreateListing) {
      return const SizedBox.shrink();
    }

    if (me.isPending) {
      return _statusBanner(
        icon: Icons.hourglass_top_rounded,
        title: 'Host application under review',
        message:
            'We\'re reviewing your host application. You\'ll be able to publish listings once approved.',
        background: const Color(0xFFFFFBEB),
        border: const Color(0xFFFDE68A),
        iconColor: const Color(0xFFD97706),
      );
    }

    if (me.isRejected) {
      return _statusBanner(
        icon: Icons.cancel_outlined,
        title: 'Host application not approved',
        message: me.rejectionReason?.isNotEmpty == true
            ? me.rejectionReason!
            : 'You can update your details and apply again.',
        background: const Color(0xFFFEF2F2),
        border: const Color(0xFFFECACA),
        iconColor: const Color(0xFFDC2626),
        actionLabel: 'Apply again',
        onAction: () => context.push(AppRoutes.hostRegister),
      );
    }

    return _statusBanner(
      icon: Icons.home_work_outlined,
      title: 'Become a Nexa host',
      message:
          'Complete host onboarding to list your property and start earning.',
      background: const Color(0xFFFFF0F5),
      border: const Color(0xFFFBCFE8),
      iconColor: const Color(0xFFE8507A),
      actionLabel: 'Start application',
      onAction: () => context.push(AppRoutes.hostRegister),
    );
  }

  Widget _statusBanner({
    required IconData icon,
    required String title,
    required String message,
    required Color background,
    required Color border,
    required Color iconColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────

  SliverAppBar _buildSliverAppBar(BuildContext context, HostDashboardLoaded state) {
    final canList = state.hostMe.canCreateListing;
    return SliverAppBar(
      expandedHeight: 80,
      backgroundColor: const Color(0xFFF9FAFB),
      surfaceTintColor: Colors.transparent,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A2E), size: 20),
        onPressed: () => context.go('/home'),
      ),
      title: Text(
        'Host Dashboard',
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: canList
                  ? const Color(0xFFE8507A)
                  : const Color(0xFF9CA3AF),
              size: 28,
            ),
            onPressed: canList
                ? () => context.push(AppRoutes.hostListProperty)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.hostMe.isPending
                              ? 'Your host application is still under review.'
                              : 'Complete host onboarding before listing a property.',
                          style: GoogleFonts.dmSans(color: Colors.white),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
          ),
        ),
      ],
    );
  }

  // ── Earnings Card ──────────────────────────────────────────────────────────

  Widget _buildEarningsCard(HostDashboardLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        // Subtle pattern or gradient overlay
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A4A),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background decorative element
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8507A).withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8507A).withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Earnings',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.earningsTrendPct >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: state.earningsTrendPct >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFDC2626),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${state.earningsTrendPct >= 0 ? '+' : ''}${state.earningsTrendPct.toStringAsFixed(0)}%',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: state.earningsTrendPct >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${state.totalEarnings.toStringAsFixed(0)} MAD',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildEarningStat(
                      label: 'This Month',
                      value: '${state.thisMonthEarnings.toStringAsFixed(0)} MAD',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _buildEarningStat(
                        label: 'Bookings',
                        value: '${state.totalBookings}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActions(HostDashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionBtn(Icons.calendar_month_rounded, 'Calendar', const Color(0xFF3B82F6), () => context.push(AppRoutes.hostCalendar))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionBtn(Icons.insights_rounded, 'Insights', const Color(0xFF8B5CF6), () => context.push(AppRoutes.hostInsights))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionBtn(Icons.star_rounded, 'Reviews', const Color(0xFFF59E0B), () => context.push(AppRoutes.hostReviews))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return _HoverScaleCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Analytics Section (fl_chart) ──────────────────────────────────────────

  Widget _buildAnalyticsSection(HostDashboardLoaded state) {
    final hasListings = state.listings.isNotEmpty;
    final pendingBookings = state.pendingBookings;
    final activeBookings = state.activeBookings;
    final totalBookings = state.totalBookings;
    final conversionRate = totalBookings == 0
        ? 0.0
        : (activeBookings / totalBookings) * 100;
    final monthlyShare = state.totalEarnings <= 0
        ? 0.0
        : (state.thisMonthEarnings / state.totalEarnings) * 100;

    final insightTitle = !hasListings
        ? 'Create your first listing'
        : pendingBookings > activeBookings
            ? 'Respond faster to pending bookings'
            : 'Great hosting momentum';
    final insightMessage = !hasListings
        ? 'Add a property to start receiving requests and performance insights.'
        : pendingBookings > activeBookings
            ? '$pendingBookings requests are pending. Faster responses can improve conversions.'
            : '$activeBookings active bookings running smoothly right now.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),

        // Dynamic insight based on current dashboard stats.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8507A).withOpacity(0.05),
            border: Border.all(color: const Color(0xFFE8507A).withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFE8507A), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insightTitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insightMessage,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildInsightMetricCard(
                label: 'Listings',
                value: '${state.listings.length}',
                subtitle: hasListings ? 'Active catalog size' : 'No listings yet',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightMetricCard(
                label: 'Active Rate',
                value: '${conversionRate.toStringAsFixed(0)}%',
                subtitle: '$activeBookings of $totalBookings bookings active',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightMetricCard(
                label: 'This Month',
                value: '${state.thisMonthEarnings.toStringAsFixed(0)} MAD',
                subtitle: '${monthlyShare.toStringAsFixed(0)}% of total earnings',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightMetricCard({
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ── Listings Section ────────────────────────────────────────────────────────

  Widget _buildListingsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Your Properties',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.hostListProperty),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add New'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE8507A),
            textStyle: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyListings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.maps_home_work_outlined, size: 48, color: Color(0xFFE8507A)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Properties Listed',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your hosting journey today. Add your first property and welcome guests.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.hostListProperty),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8507A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              elevation: 0,
            ),
            child: Text(
              'List Property',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, Property property) {
    final rawStatus = property.listingStatus.toUpperCase();
    final status = switch (rawStatus) {
      'PAUSED' => ListingStatus.paused,
      'SUBMITTED' || 'UNDER_REVIEW' => ListingStatus.underReview,
      'REJECTED' => ListingStatus.rejected,
      'DRAFT' => ListingStatus.draft,
      _ => ListingStatus.live,
    };

    return _HoverScaleCard(
      onTap: () {
        context.push(AppRoutes.hostPropertyManageOf(property.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            SizedBox(
              width: 120,
              child: Image.network(
                property.imageUrl.isNotEmpty
                    ? property.imageUrl
                    : property.images.isNotEmpty ? property.images.first : 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?q=80&w=200',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ListingStatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.city,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${property.pricePerNight.toInt()} MAD',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE8507A),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Hover Scale Card Animation
// =============================================================================

class _HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverScaleCard({required this.child, required this.onTap});

  @override
  State<_HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<_HoverScaleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: IntrinsicHeight(child: widget.child),
      ),
    );
  }
}
