import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../data/models/host_reviews_payload.dart';
import 'bloc/host_reviews_cubit.dart';
import 'bloc/host_reviews_state.dart';

class HostReviewsPage extends StatefulWidget {
  const HostReviewsPage({super.key});

  @override
  State<HostReviewsPage> createState() => _HostReviewsPageState();
}

class _HostReviewsPageState extends State<HostReviewsPage> {
  final _scrollCtrl = ScrollController();
  late final HostReviewsCubit _cubit = getIt<HostReviewsCubit>();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cubit.load();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels > pos.maxScrollExtent - 280) {
      _cubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Guest Reviews',
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
      body: BlocBuilder<HostReviewsCubit, HostReviewsState>(
        builder: (context, state) {
          if (state is HostReviewsInitial || state is HostReviewsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            );
          }
          if (state is HostReviewsError) {
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
                    TextButton(
                      onPressed: () => context.read<HostReviewsCubit>().refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final loaded = state as HostReviewsLoaded;
          final sum = loaded.payload.summary;
          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverToBoxAdapter(
                child: _OverallRatingPanel(summary: sum),
              ),
              if (loaded.payload.reviews.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No guest reviews yet — they will appear here after stays are completed.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _ReviewCard(item: loaded.payload.reviews[index]),
                      childCount: loaded.payload.reviews.length,
                    ),
                  ),
                ),
              if (loaded.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
    );
  }
}

class _OverallRatingPanel extends StatelessWidget {
  const _OverallRatingPanel({required this.summary});

  final HostReviewsSummary summary;

  @override
  Widget build(BuildContext context) {
    final avg = summary.overallAvgRating;
    final display = avg != null ? avg.toStringAsFixed(1) : '—';
    final total = summary.totalCount;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Rating',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      display,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '/ 5.0',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  total == 1 ? 'Based on 1 review' : 'Based on $total reviews',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (var star = 5; star >= 1; star--)
                  Padding(
                    padding: EdgeInsets.only(bottom: star > 1 ? 4 : 0),
                    child: _StarBar(
                      stars: star,
                      fraction: summary.distributionPct[star] ?? 0,
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

class _StarBar extends StatelessWidget {
  const _StarBar({required this.stars, required this.fraction});

  final int stars;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final r = fraction.clamp(0.0, 1.0);
    return Row(
      children: [
        Text(
          '$stars',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * r,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item});

  final HostReviewItem item;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(item.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF3F4F6),
                child: Text(
                  item.guestName.isNotEmpty
                      ? item.guestName.substring(0, 1).toUpperCase()
                      : '?',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.guestName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      item.listingTitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < item.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (item.comment.isNotEmpty)
            Text(
              item.comment,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            dateStr,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
