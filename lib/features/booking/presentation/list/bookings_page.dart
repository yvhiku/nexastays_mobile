import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../navigation/app_routes.dart';
import '../../../../navigation/bottom_navigation.dart';
import 'bloc/bookings_cubit.dart';
import 'bloc/bookings_state.dart';
import 'widgets/booking_card.dart';
import 'widgets/bookings_empty_state.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<BookingsCubit>().loadBookings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(BookingsTab tab) {
    context.read<BookingsCubit>().switchTab(tab);
    int pageIndex = tab == BookingsTab.upcoming ? 0 : 1;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
              const Text(
                'Cancel booking?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please let us know why you are cancelling.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (val) => reason = val,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Reason for cancellation (min 10 chars)',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
              const SizedBox(height: 12),
              const Text(
                'Cancellation policy: Depending on the host\'s policy, you may not receive a full refund.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
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
                      child: const Text(
                        'Keep booking',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
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
          bool isLoading = state is BookingsLoading || state is BookingsInitial;
          BookingsTab activeTab = BookingsTab.upcoming;
          if (state is BookingsLoaded) activeTab = state.activeTab;
          if (state is BookingsEmpty) activeTab = state.tab;

          return Column(
            children: [
              // Custom Tab Bar
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTabItem(
                      'Upcoming',
                      activeTab == BookingsTab.upcoming,
                      () => _onTabTapped(BookingsTab.upcoming),
                    ),
                    _buildTabItem(
                      'Past',
                      activeTab == BookingsTab.past,
                      () => _onTabTapped(BookingsTab.past),
                    ),
                  ],
                ),
              ),

              // Page View Body
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
                        ),
                      )
                    : PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildUpcomingPage(state),
                          _buildPastPage(state),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NexaBottomNavigation(
        currentIndex: 3, // Profile tab index
        onTabChanged: (index) {
          // Navigation logic handled externally or pushed here
          if (index == 0) context.go(AppRoutes.home);
          if (index == 1) context.go(AppRoutes.explore);
          if (index == 2) context.go(AppRoutes.saved);
        },
      ),
    );
  }

  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFFE8507A) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
              color: isActive ? const Color(0xFFE8507A) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingPage(BookingsState state) {
    if (state is BookingsEmpty && state.tab == BookingsTab.upcoming) {
      return BookingsEmptyState(
        isUpcoming: true,
        onExplore: () => context.go(AppRoutes.explore),
      );
    }
    
    if (state is BookingsLoaded && state.upcomingBookings.isEmpty) {
      return BookingsEmptyState(
        isUpcoming: true,
        onExplore: () => context.go(AppRoutes.explore),
      );
    }

    if (state is BookingsLoaded) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.upcomingBookings.length,
        itemBuilder: (context, index) {
          final booking = state.upcomingBookings[index];
          return BookingCard(
            booking: booking,
            onViewDetails: () {
              context.push(AppRoutes.bookingDetailOf(booking.id), extra: booking);
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
            onCancel: () => _showCancellationBottomSheet(context, booking.id),
          );
        },
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildPastPage(BookingsState state) {
    if (state is BookingsEmpty && state.tab == BookingsTab.past) {
      return const BookingsEmptyState(isUpcoming: false);
    }
    
    if (state is BookingsLoaded && state.pastBookings.isEmpty) {
      return const BookingsEmptyState(isUpcoming: false);
    }

    if (state is BookingsLoaded) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.pastBookings.length,
        itemBuilder: (context, index) {
          final booking = state.pastBookings[index];
          return BookingCard(
            booking: booking,
            onViewDetails: () {
              context.push(AppRoutes.bookingDetailOf(booking.id), extra: booking);
            },
            onReview: () {
                 // Navigator.pushNamed(context, '/review', arguments: booking);
            },
          );
        },
      );
    }

    return SizedBox.shrink();
  }
}
