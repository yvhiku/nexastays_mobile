import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final VoidCallback? onPay;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onViewDetails,
    this.onCancel,
    this.onReview,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000), // 0.07 alpha
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TOP IMAGE STRIP
          SizedBox(
            height: 140,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (booking.propertyPhotoUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: booking.propertyPhotoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
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
                        _photoPlaceholder(),
                  )
                else
                  _photoPlaceholder(),
                Positioned(
                  top: 12,
                  right: 12,
                  child: BookingStatusBadge(status: booking.status),
                ),
              ],
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.propertyNeighborhood}, ${booking.propertyCity}'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.propertyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('📅 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '${booking.dateRangeDisplay} · ${booking.nightsDisplay}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('👥 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '${booking.guests} guest${booking.guests > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${booking.feeBreakdown.totalGuestPays.toInt()} MAD total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFE8507A),
                      ),
                    ),
                    const Text(
                      'All fees included',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // DIVIDER
          const Divider(color: Color(0xFFF3F4F6), height: 1, thickness: 1),

          // ACTION ROW
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.active) ...[
                  GestureDetector(
                    onTap: onViewDetails,
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFE8507A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Text('📍 ', style: TextStyle(fontSize: 10)),
                        Text(
                          'Contact shared',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (booking.status == BookingStatus.paymentPending) ...[
                  GestureDetector(
                    onTap: onPay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8507A),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        'Pay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onViewDetails,
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFE8507A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ] else if (booking.status == BookingStatus.pending) ...[
                  GestureDetector(
                    onTap: onViewDetails,
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFE8507A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ] else if (booking.status == BookingStatus.completed) ...[
                  GestureDetector(
                    onTap: onViewDetails,
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFE8507A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onReview,
                    child: const Text(
                      'Write a review',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ] else if (booking.status == BookingStatus.cancelled || booking.status == BookingStatus.rejected) ...[
                  GestureDetector(
                    onTap: onViewDetails,
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  if (booking.cancellationReason != null) ...[
                    const Spacer(),
                    Expanded(
                      child: Text(
                        booking.cancellationReason!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child: Icon(Icons.home_outlined, color: Color(0xFF9CA3AF), size: 40),
      ),
    );
  }
}

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case BookingStatus.paymentPending:
        bgColor = const Color(0xFFFFF0F5);
        textColor = const Color(0xFFE8507A);
        label = 'Payment pending';
        break;
      case BookingStatus.pending:
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFD97706);
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF16A34A);
        label = 'Confirmed';
        break;
      case BookingStatus.active:
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        label = 'Active';
        break;
      case BookingStatus.completed:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
        label = 'Completed';
        break;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        label = status == BookingStatus.rejected ? 'Rejected' : 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: textColor,
        ),
      ),
    );
  }
}
