import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../home/domain/entities/property.dart';
import '../domain/entities/host_property_manage_data.dart';
import 'bloc/host_property_manage_cubit.dart';
import 'bloc/host_property_manage_state.dart';
import '../../../navigation/app_routes.dart';
import 'widgets/listing_status_badge.dart';

class HostPropertyManagePage extends StatefulWidget {
  final String propertyId;

  const HostPropertyManagePage({super.key, required this.propertyId});

  @override
  State<HostPropertyManagePage> createState() => _HostPropertyManagePageState();
}

class _HostPropertyManagePageState extends State<HostPropertyManagePage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<HostPropertyManageCubit>().load(widget.propertyId);
  }

  Future<void> _reload() async {
    await context.read<HostPropertyManageCubit>().load(widget.propertyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Manage Property',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<HostPropertyManageCubit, HostPropertyManageState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.edit_square,
                    color: Color(0xFFE8507A), size: 24),
                onPressed: state is HostPropertyManageLoaded
                    ? () async {
                        final updated = await context.pushNamed<bool>(
                          'hostListingEdit',
                          pathParameters: {'id': widget.propertyId},
                        );
                        if (updated == true && context.mounted) {
                          context
                              .read<HostPropertyManageCubit>()
                              .load(widget.propertyId);
                        }
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HostPropertyManageCubit, HostPropertyManageState>(
        builder: (context, state) {
          if (state is HostPropertyManageInitial ||
              state is HostPropertyManageLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            );
          }

          if (state is HostPropertyManageError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(color: const Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<HostPropertyManageCubit>()
                          .load(widget.propertyId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8507A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = (state as HostPropertyManageLoaded).data;
          return RefreshIndicator(
            color: const Color(0xFFE8507A),
            onRefresh: _reload,
            child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildPropertyHeader(data.property)),
              SliverToBoxAdapter(child: _buildTabs()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              if (_selectedTab == 0)
                SliverToBoxAdapter(child: _buildOverviewTab(data)),
              if (_selectedTab == 1)
                SliverToBoxAdapter(child: _buildHistoryTab(data)),
              if (_selectedTab == 2)
                SliverToBoxAdapter(child: _buildSettingsTab(data)),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyHeader(Property property) {
    final status = _mapListingStatus(property.listingStatus);
    final imageUrl = property.imageUrl.isNotEmpty
        ? property.imageUrl
        : (property.images.isNotEmpty ? property.images.first : '');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF3F4F6),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListingStatusBadge(status: status),
                const SizedBox(height: 4),
                Text(
                  property.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  property.address.trim().isNotEmpty
                      ? property.address
                      : property.city,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListingStatus _mapListingStatus(String raw) {
    final status = raw.toUpperCase();
    return switch (status) {
      'PAUSED' => ListingStatus.paused,
      'SUBMITTED' || 'UNDER_REVIEW' => ListingStatus.underReview,
      'REJECTED' => ListingStatus.rejected,
      'DRAFT' => ListingStatus.draft,
      _ => ListingStatus.live,
    };
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildTab(0, 'Overview'),
          const SizedBox(width: 12),
          _buildTab(1, 'History'),
          const SizedBox(width: 12),
          _buildTab(2, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFE8507A) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFFE8507A) : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(HostPropertyManageData data) {
    final analytics = data.analytics;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Earnings YTD',
                  '${_formatAmount(analytics.earningsYtd)} MAD',
                  analytics.earningsTrendPct,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Occupancy',
                  '${analytics.occupancyPercent.toStringAsFixed(0)}%',
                  analytics.occupancyTrendPct,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildChart(analytics),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, double trendPct) {
    final isPositive = trendPct >= 0;
    final trendText =
        '${isPositive ? '+' : ''}${trendPct.toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$trendText vs last month',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(PropertyListingAnalytics analytics) {
    final points = analytics.monthlyEarnings;
    final maxAmount = points.fold<double>(
      0,
      (max, point) => point.amount > max ? point.amount : max,
    );
    final chartMaxY = maxAmount <= 0 ? 1.0 : maxAmount * 1.2;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings History',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: points.every((p) => p.amount == 0)
                ? Center(
                    child: Text(
                      'No earnings yet for this listing',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: Color(0xFFF3F4F6),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                points[index].label,
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (points.length - 1).toDouble(),
                      minY: 0,
                      maxY: chartMaxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < points.length; i++)
                              FlSpot(i.toDouble(), points[i].amount),
                          ],
                          isCurved: true,
                          color: const Color(0xFF10B981),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF10B981).withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(HostPropertyManageData data) {
    final bookings = data.pastBookings;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Past Bookings',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          if (bookings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Text(
                'No bookings yet for this property.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            )
          else
            ...bookings.map(_buildHistoryCard),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(PropertyBookingHistoryItem booking) {
    final dateFormat = DateFormat('MMM d');
    final yearFormat = DateFormat('yyyy');
    final dates =
        '${dateFormat.format(booking.checkIn)} - ${dateFormat.format(booking.checkOut)}, ${yearFormat.format(booking.checkOut)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF3F4F6),
            child: Text(
              booking.guestName.isNotEmpty ? booking.guestName[0].toUpperCase() : 'G',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.guestName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  dates,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatAmount(booking.amount)} ${booking.currency}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                booking.statusLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: booking.isCancelled
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(HostPropertyManageData data) {
    final status = data.property.listingStatus.toUpperCase();
    final canPause = status == 'LIVE' || status == 'APPROVED';
    final canResume = status == 'PAUSED';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingItem(
            Icons.monetization_on_outlined,
            'Pricing & Discounts',
            'Update nightly rate and custom pricing.',
            onTap: () => _openEditSection('pricing'),
          ),
          _buildSettingItem(
            Icons.rule_folder_outlined,
            'House Rules',
            'Update check-in times and policies.',
            onTap: () => _openEditSection('rules'),
          ),
          _buildSettingItem(
            Icons.calendar_month_outlined,
            'Availability Calendar',
            'View booked dates for this property.',
            onTap: () => context.push(AppRoutes.hostCalendar),
          ),
          if (canPause)
            _buildSettingItem(
              Icons.pause_circle_outline,
              'Pause Listing',
              'Temporarily hide from search results.',
              isDestructive: true,
              onTap: () => _confirmPause(),
            ),
          if (canResume)
            _buildSettingItem(
              Icons.play_circle_outline,
              'Resume Listing',
              'Make this listing visible in search again.',
              onTap: () => _confirmResume(),
            ),
        ],
      ),
    );
  }

  Future<void> _openEditSection(String section) async {
    final updated = await context.pushNamed<bool>(
      'hostListingEdit',
      pathParameters: {'id': widget.propertyId},
      queryParameters: {'section': section},
    );
    if (updated == true && mounted) {
      context.read<HostPropertyManageCubit>().load(widget.propertyId);
    }
  }

  Future<void> _confirmPause() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pause listing?', style: GoogleFonts.playfairDisplay()),
        content: Text(
          'Guests will no longer find this property in search until you resume it.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pause'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await context
        .read<HostPropertyManageCubit>()
        .pauseListing(widget.propertyId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message,
          style: GoogleFonts.dmSans(color: Colors.white),
        ),
        backgroundColor:
            result.success ? const Color(0xFF1A1A2E) : const Color(0xFFDC2626),
      ),
    );
  }

  Future<void> _confirmResume() async {
    final result = await context
        .read<HostPropertyManageCubit>()
        .resumeListing(widget.propertyId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message,
          style: GoogleFonts.dmSans(color: Colors.white),
        ),
        backgroundColor:
            result.success ? const Color(0xFF10B981) : const Color(0xFFDC2626),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xFFFEF2F2) : const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF1A1A2E),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
        onTap: onTap,
      ),
    );
  }

  String _formatAmount(double value) {
    final rounded = value.round();
    return NumberFormat.decimalPattern().format(rounded);
  }
}
