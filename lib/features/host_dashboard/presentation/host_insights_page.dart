import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/host_dashboard_cubit.dart';
import 'bloc/host_dashboard_state.dart';

class HostInsightsPage extends StatefulWidget {
  const HostInsightsPage({super.key});

  @override
  State<HostInsightsPage> createState() => _HostInsightsPageState();
}

class _HostInsightsPageState extends State<HostInsightsPage> {
  int _selectedTab = 0; // 0: Earnings, 1: Views, 2: Bookings

  @override
  void initState() {
    super.initState();
    context.read<HostDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Insights',
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
      ),
      body: BlocBuilder<HostDashboardCubit, HostDashboardState>(
        builder: (context, state) {
          if (state is HostDashboardLoading || state is HostDashboardInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            );
          }
          if (state is HostDashboardError) {
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<HostDashboardCubit>().loadDashboard(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = state as HostDashboardLoaded;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTabs()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(child: _buildSummaryCards(data)),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: _buildSnapshotPanel(data)),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildTab(0, 'Earnings'),
          const SizedBox(width: 12),
          _buildTab(1, 'Views'),
          const SizedBox(width: 12),
          _buildTab(2, 'Bookings'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(HostDashboardLoaded data) {
    final totalListings = data.listings.length;
    final totalBookings = data.totalBookings;
    final pendingBookings = data.pendingBookings;
    final activeBookings = data.activeBookings;
    final conversionRate =
        totalBookings == 0 ? 0.0 : (activeBookings / totalBookings) * 100;

    final primaryTitle = _selectedTab == 0
        ? 'Total Earnings'
        : (_selectedTab == 1 ? 'Total Listings' : 'Total Bookings');
    final primaryValue = _selectedTab == 0
        ? '${data.totalEarnings.toStringAsFixed(0)} MAD'
        : (_selectedTab == 1 ? '$totalListings' : '$totalBookings');
    final primaryTrend = _selectedTab == 0
        ? '${data.thisMonthEarnings.toStringAsFixed(0)} MAD this month'
        : (_selectedTab == 1
            ? '$pendingBookings under review'
            : '${conversionRate.toStringAsFixed(0)}% active');

    final secondaryTitle =
        _selectedTab == 2 ? 'Pending bookings' : 'This month';
    final secondaryValue = _selectedTab == 0
        ? '${data.thisMonthEarnings.toStringAsFixed(0)} MAD'
        : (_selectedTab == 1 ? '$pendingBookings' : '$pendingBookings');
    final secondaryTrend = _selectedTab == 0
        ? 'Current month earnings'
        : (_selectedTab == 1 ? 'Listings awaiting actions' : 'Awaiting host action');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildCard(
              title: primaryTitle,
              value: primaryValue,
              trend: primaryTrend,
              isPositive: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCard(
              title: secondaryTitle,
              value: secondaryValue,
              trend: secondaryTrend,
              isPositive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String value, required String trend, required bool isPositive}) {
    return Container(
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
            title,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isPositive ? Icons.insights_rounded : Icons.info_outline_rounded,
                color: isPositive ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trend,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotPanel(HostDashboardLoaded data) {
    final totalListings = data.listings.length;
    final submittedListings = data.listings
        .where((l) => l.listingStatus.toUpperCase() == 'SUBMITTED')
        .length;
    final liveListings = data.listings
        .where((l) => l.listingStatus.toUpperCase() == 'LIVE')
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
              'Snapshot',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            _snapshotRow('Total listings', '$totalListings'),
            _snapshotRow('Live listings', '$liveListings'),
            _snapshotRow('Under review listings', '$submittedListings'),
            _snapshotRow('Pending bookings', '${data.pendingBookings}'),
            _snapshotRow('Active bookings', '${data.activeBookings}'),
          ],
        ),
      ),
    );
  }

  Widget _snapshotRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
