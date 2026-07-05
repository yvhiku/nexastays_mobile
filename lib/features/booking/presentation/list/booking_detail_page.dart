import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/di/injection.dart';
import '../../../../navigation/app_routes.dart';

import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../create/widgets/checkin_contact_card.dart';
import '../create/widgets/fee_breakdown_card.dart';
import 'widgets/booking_review_sheet.dart';

class BookingDetailPage extends StatefulWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late Booking _booking;
  bool _isRefreshing = true;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _refreshBooking();
  }

  Future<void> _refreshBooking() async {
    final result =
        await getIt<BookingRepository>().getBookingById(widget.booking.id);
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
      result.fold((_) {}, (fresh) => _booking = fresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        title: const Text(
          'Booking details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, size: 22),
            onPressed: () {
              // Share booking details
            },
          ),
        ],
      ),
      body: _isRefreshing
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // STATUS BANNER
            _buildStatusBanner(),
            const SizedBox(height: 24),

            // PROPERTY CARD
            _buildPropertyCard(context),
            const SizedBox(height: 24),

            // STAY DATES CARD
            _buildStayDatesCard(),
            const SizedBox(height: 24),

            // CHECKIN CONTACT CARD
            CheckinContactCard(
              booking: _booking,
              isRevealed: _booking.contactRevealed,
            ),
            const SizedBox(height: 24),

            // FEE BREAKDOWN
            FeeBreakdownCard(
              feeBreakdown: _booking.feeBreakdown,
              showFull: true,
            ),
            const SizedBox(height: 24),

            // BOOKING INFO ROWS
            _buildBookingInfoCard(),
            const SizedBox(height: 32),

            // ACTION BUTTONS
            if (_booking.needsPayment) ...[
              ElevatedButton(
                onPressed: () async {
                  final paid = await context.push<bool>(
                    AppRoutes.bookingCheckoutOf(_booking.id),
                    extra: _booking,
                  );
                  if (paid == true && context.mounted) {
                    await _refreshBooking();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8507A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Pay ${_booking.feeBreakdown.totalGuestPays.toInt()} MAD',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_booking.canCancel) ...[
              OutlinedButton(
                onPressed: () {
                  // show cancellation bottom sheet
                  // typically handled via Bloc/dialogs in the main page or here
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Cancel booking',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_booking.canDispute) ...[
              OutlinedButton(
                onPressed: () {
                  context.push(AppRoutes.openDispute, extra: {
                    'bookingId': _booking.id,
                    'propertyId': _booking.propertyId,
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE8507A), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Open a dispute',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFE8507A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_booking.status == BookingStatus.completed) ...[
              ElevatedButton(
                onPressed: () async {
                  final submitted = await showBookingReviewSheet(
                    context: context,
                    bookingId: _booking.id,
                  );
                  if (submitted == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your review!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8507A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Write a review',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.black;
    IconData icon = Icons.info;
    String text = '';

    switch (_booking.status) {
      case BookingStatus.paymentPending:
        bgColor = const Color(0xFFFFF0F5);
        borderColor = const Color(0xFFF5D0DA);
        textColor = const Color(0xFFE8507A);
        icon = Icons.payment;
        text = 'Payment required to confirm your booking';
        break;
      case BookingStatus.confirmed:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        textColor = const Color(0xFF16A34A);
        icon = Icons.check_circle;
        text = 'Booking confirmed';
        break;
      case BookingStatus.pending:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFFD97706);
        icon = Icons.hourglass_empty;
        text = 'Awaiting confirmation';
        break;
      case BookingStatus.active:
        bgColor = const Color(0xFFE0F2FE);
        borderColor = const Color(0xFFBAE6FD);
        textColor = const Color(0xFF0284C7);
        icon = Icons.home;
        text = 'You\'re staying here!';
        break;
      case BookingStatus.completed:
        bgColor = const Color(0xFFF3F4F6);
        borderColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF4B5563);
        icon = Icons.check_circle;
        text = 'Stay completed';
        break;
      case BookingStatus.cancelled:
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        textColor = const Color(0xFFDC2626);
        icon = Icons.cancel;
        text = 'Booking cancelled';
        break;
      case BookingStatus.rejected:
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        textColor = const Color(0xFFDC2626);
        icon = Icons.cancel;
        text = 'Booking rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.propertyDetailOf(_booking.propertyId));
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _booking.propertyPhotoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _booking.propertyPhotoUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 90,
                        height: 90,
                        color: const Color(0xFFE5E7EB),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE8507A),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _listingThumbPlaceholder(),
                    )
                  : _listingThumbPlaceholder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_booking.propertyNeighborhood}, ${_booking.propertyCity}'
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _booking.propertyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFE8507A), size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        'Hosted by ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _booking.displayHostName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF374151),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStayDatesCard() {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    // Mocks standard Check-in/out times
    final defaultCheckInTime = DateTime(_booking.checkIn.year,
        _booking.checkIn.month, _booking.checkIn.day, 15, 0);
    final defaultCheckOutTime = DateTime(_booking.checkOut.year,
        _booking.checkOut.month, _booking.checkOut.day, 11, 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-in',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(_booking.checkIn),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeFormat.format(defaultCheckInTime),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Checkout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(_booking.checkOut),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeFormat.format(defaultCheckOutTime),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_booking.nightsDisplay} · ${_booking.guests} guest${_booking.guests > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildInfoRow(
              'Booking ID', '#${_booking.id.substring(0, 8).toUpperCase()}',
              isBold: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          _buildInfoRow('Booked on', dateFormat.format(_booking.createdAt)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          _buildInfoRow('Payment', 'Secured by Nexa Stays'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          _buildInfoRow(
            'Cancellation',
            _booking.canCancel
                ? 'Free cancellation before check-in depending on host policy.'
                : 'Past cancellation window.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listingThumbPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFFE5E7EB),
      child: const Icon(Icons.home_outlined, color: Color(0xFF9CA3AF)),
    );
  }
}
