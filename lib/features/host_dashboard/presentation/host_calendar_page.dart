import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/session/session_manager.dart';
import '../../booking/domain/entities/booking.dart';
import '../../booking/domain/repositories/booking_repository.dart';

class HostCalendarPage extends StatefulWidget {
  const HostCalendarPage({super.key});

  @override
  State<HostCalendarPage> createState() => _HostCalendarPageState();
}

class _HostCalendarPageState extends State<HostCalendarPage> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  String? _error;
  List<Booking> _bookings = const [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final userId = getIt<SessionManager>().userId;
    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Please sign in to view your calendar.';
      });
      return;
    }

    final result = await getIt<BookingRepository>().getHostBookings(userId);
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (bookings) => setState(() {
        _loading = false;
        _bookings = bookings
            .where((b) => b.status != BookingStatus.cancelled)
            .toList();
      }),
    );
  }

  Map<String, List<Booking>> _bookingsByDateKey() {
    final map = <String, List<Booking>>{};
    for (final booking in _bookings) {
      var day = DateTime(
        booking.checkIn.year,
        booking.checkIn.month,
        booking.checkIn.day,
      );
      final end = DateTime(
        booking.checkOut.year,
        booking.checkOut.month,
        booking.checkOut.day,
      );
      while (day.isBefore(end)) {
        final key = '${day.year}-${day.month}-${day.day}';
        map.putIfAbsent(key, () => []).add(booking);
        day = day.add(const Duration(days: 1));
      }
    }
    return map;
  }

  List<Booking> _bookingsOn(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    return _bookingsByDateKey()[key] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Calendar',
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            )
          : _error != null
              ? Center(child: Text(_error!, style: GoogleFonts.dmSans()))
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildCalendarHeader()),
                    SliverToBoxAdapter(child: _buildCalendarGrid()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(child: _buildBookingsForSelectedDate()),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
                color: Color(0xFF1A1A2E)),
            onPressed: () {
              setState(() {
                _focusedDate =
                    DateTime(_focusedDate.year, _focusedDate.month - 1);
              });
            },
          ),
          Text(
            '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF1A1A2E)),
            onPressed: () {
              setState(() {
                _focusedDate =
                    DateTime(_focusedDate.year, _focusedDate.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);
    final firstDayOffset =
        DateTime(_focusedDate.year, _focusedDate.month, 1).weekday % 7;
    final byDate = _bookingsByDateKey();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayOffset + 1;
              if (index < firstDayOffset || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date =
                  DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final key = '${date.year}-${date.month}-${date.day}';
              final isBooked = byDate.containsKey(key);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8507A)
                        : (isBooked
                            ? const Color(0xFFE8507A).withOpacity(0.1)
                            : Colors.transparent),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isBooked
                                ? const Color(0xFFE8507A).withOpacity(0.5)
                                : Colors.transparent,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight:
                            isSelected || isBooked ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isBooked
                                ? const Color(0xFFE8507A)
                                : const Color(0xFF1A1A2E)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBookingsForSelectedDate() {
    final bookings = _bookingsOn(_selectedDate);
    final dateLabel = DateFormat('d MMM yyyy').format(_selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings on $dateLabel',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          if (bookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Center(
                child: Text(
                  'No bookings for this date.',
                  style: GoogleFonts.dmSans(color: const Color(0xFF6B7280)),
                ),
              ),
            )
          else
            ...bookings.map(_buildBookingCard),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final guest = booking.guestName.isNotEmpty ? booking.guestName : 'Guest';
    final range =
        '${DateFormat('MMM d').format(booking.checkIn)} – ${DateFormat('MMM d').format(booking.checkOut)}';

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8507A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_work_rounded, color: Color(0xFFE8507A)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.propertyName,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '$guest • $range',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
