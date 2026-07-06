import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/booking_lifecycle.dart';
import '../../../../navigation/app_routes.dart';
import '../../../../navigation/bottom_navigation.dart';
import 'bloc/bookings_cubit.dart';
import 'bloc/bookings_state.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_filters_sheet.dart';
import 'widgets/booking_tabs_bar.dart';
import 'widgets/booking_review_sheet.dart';
import 'widgets/bookings_empty_state.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BookingsCubit>().loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCancellationBottomSheet(BuildContext context, String bookingId) {
    final cubit = context.read<BookingsCubit>();
    String reason = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancel booking?',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please let us know why you are cancelling.',
                style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (val) => reason = val,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Reason for cancellation (min 10 chars)',
                  hintStyle:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8507A)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text('Keep booking'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (reason.trim().length >= 10) {
                          cubit.cancelBooking(bookingId, reason.trim());
                          Navigator.pop(bottomSheetContext);
                        } else {
                          ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter at least 10 characters.'),
                              backgroundColor: Color(0xFFDC2626),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm cancellation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocConsumer<BookingsCubit, BookingsState>(
        listener: (context, state) {
          if (state is BookingCancelSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking cancelled successfully'),
                backgroundColor: Color(0xFF16A34A),
              ),
            );
          } else if (state is BookingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingsLoading || state is BookingsInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            );
          }

          if (state is BookingsEmpty) {
            return BookingsEmptyState(
              onExplore: () => context.go(AppRoutes.explore),
            );
          }

          if (state is! BookingsLoaded) {
            return const SizedBox.shrink();
          }

          final loaded = state;
          final hasActiveFilters = loaded.filters.search.isNotEmpty ||
              loaded.filters.dateFrom != null ||
              loaded.filters.dateTo != null ||
              loaded.filters.status != null ||
              loaded.filters.city != null ||
              loaded.filters.priceMin != null ||
              loaded.filters.priceMax != null ||
              loaded.filters.sort != BookingSort.newest;

          return RefreshIndicator(
            color: const Color(0xFFE8507A),
            onRefresh: () => context.read<BookingsCubit>().loadBookings(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'View, manage, and track all your bookings in one place.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: context.read<BookingsCubit>().setSearch,
                            decoration: InputDecoration(
                              hintText: 'Search property, ID, or city…',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: IconButton(
                            onPressed: () => BookingFiltersSheet.show(
                              context,
                              initial: loaded.filters,
                              cities: loaded.cities,
                              onApply: context.read<BookingsCubit>().applyFilters,
                              onClear: context.read<BookingsCubit>().clearFilters,
                            ),
                            icon: const Icon(Icons.tune, color: Color(0xFF374151)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: BookingTabsBar(
                      activeTab: loaded.activeTab,
                      counts: loaded.tabCounts,
                      onTabSelected: context.read<BookingsCubit>().switchTab,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tabSectionTitle(loaded.activeTab),
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tabSectionDescription(loaded.activeTab),
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (loaded.filteredBookings.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: BookingsEmptyState(
                      tab: loaded.activeTab,
                      filtered: hasActiveFilters ||
                          loaded.filters.search.isNotEmpty,
                      onExplore: () => context.go(AppRoutes.explore),
                      onClearFilters: () {
                        _searchController.clear();
                        context.read<BookingsCubit>().clearFilters();
                        context.read<BookingsCubit>().setSearch('');
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < loaded.visibleBookings.length) {
                            final booking = loaded.visibleBookings[index];
                            return BookingCard(
                              booking: booking,
                              onViewDetails: () {
                                context.push(
                                  AppRoutes.bookingDetailOf(booking.id),
                                  extra: booking,
                                );
                              },
                              onPay: () async {
                                final paid = await context.push<bool>(
                                  AppRoutes.bookingCheckoutOf(booking.id),
                                  extra: booking,
                                );
                                if (paid == true && context.mounted) {
                                  context.read<BookingsCubit>().refresh();
                                }
                              },
                              onCancel: () =>
                                  _showCancellationBottomSheet(context, booking.id),
                              onReview: () async {
                                await showBookingReviewSheet(
                                  context: context,
                                  bookingId: booking.id,
                                );
                                if (context.mounted) {
                                  context.read<BookingsCubit>().refresh();
                                }
                              },
                              onBookAgain: () {
                                context.push(
                                  AppRoutes.propertyDetailOf(booking.propertyId),
                                );
                              },
                            );
                          }
                          if (loaded.hasMore) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: OutlinedButton(
                                onPressed:
                                    context.read<BookingsCubit>().loadMore,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text('Load more'),
                              ),
                            );
                          }
                          return const SizedBox(height: 24);
                        },
                        childCount: loaded.visibleBookings.length +
                            (loaded.hasMore ? 1 : 1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NexaBottomNavigation(
        currentIndex: 3,
        onTabChanged: (index) {
          if (index == 0) context.go(AppRoutes.home);
          if (index == 1) context.go(AppRoutes.explore);
          if (index == 2) context.go(AppRoutes.saved);
        },
      ),
    );
  }
}
