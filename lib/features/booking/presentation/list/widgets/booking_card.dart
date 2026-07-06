import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/booking_lifecycle.dart';
import '../../../domain/entities/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final VoidCallback? onPay;
  final VoidCallback? onBookAgain;
  final VoidCallback? onReportIssue;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onViewDetails,
    this.onCancel,
    this.onReview,
    this.onPay,
    this.onBookAgain,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final lifecycle = resolveBookingLifecycle(booking);
    final colors = lifecycleColors(lifecycle);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (booking.propertyPhotoUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: booking.propertyPhotoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _photoPlaceholder(),
                    errorWidget: (_, __, ___) => _photoPlaceholder(),
                  )
                else
                  _photoPlaceholder(),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _LifecycleBadge(
                    label: lifecycleLabel(lifecycle),
                    colors: colors,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.propertyName,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.propertyCity,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat.MMMd().format(booking.checkIn)} – ${DateFormat.MMMd().format(booking.checkOut)} · ${booking.guests} guest${booking.guests == 1 ? '' : 's'}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${booking.feeBreakdown.totalGuestPays.toInt()} MAD',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (lifecycle == BookingLifecycle.pendingPayment) ...[
                  const SizedBox(height: 8),
                  _PaymentCountdown(
                    expiresAt: booking.paymentExpiresAt ??
                        getPaymentExpiresAt(booking.createdAt),
                  ),
                ],
                if (booking.paymentFailed) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Payment failed — retry from details',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _ActionRow(
              lifecycle: lifecycle,
              booking: booking,
              onViewDetails: onViewDetails,
              onCancel: onCancel,
              onReview: onReview,
              onPay: onPay,
              onBookAgain: onBookAgain,
              onReportIssue: onReportIssue,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFFF9FAFB),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ID: ${booking.id.substring(0, 8)}…',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Text(
                  'Booked ${DateFormat.MMMd().format(booking.createdAt)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
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

  static Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child: Icon(Icons.home_outlined, color: Color(0xFF9CA3AF), size: 40),
      ),
    );
  }
}

class _LifecycleBadge extends StatelessWidget {
  const _LifecycleBadge({required this.label, required this.colors});

  final String label;
  final LifecycleColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.foreground.withValues(alpha: 0.15)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.foreground,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _PaymentCountdown extends StatefulWidget {
  const _PaymentCountdown({required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_PaymentCountdown> createState() => _PaymentCountdownState();
}

class _PaymentCountdownState extends State<_PaymentCountdown> {
  Timer? _timer;
  String _remaining = '';

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = widget.expiresAt.difference(DateTime.now());
    if (!mounted) return;
    setState(() {
      if (diff.isNegative) {
        _remaining = '00:00';
      } else {
        final mins = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
        final secs = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
        final hours = diff.inHours;
        _remaining = hours > 0 ? '${hours}h $mins:$secs' : '$mins:$secs';
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.credit_card, size: 14, color: Color(0xFFC2410C)),
        const SizedBox(width: 6),
        Text(
          'Payment expires in $_remaining',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFC2410C),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.lifecycle,
    required this.booking,
    required this.onViewDetails,
    this.onCancel,
    this.onReview,
    this.onPay,
    this.onBookAgain,
    this.onReportIssue,
  });

  final BookingLifecycle lifecycle;
  final Booking booking;
  final VoidCallback onViewDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;
  final VoidCallback? onPay;
  final VoidCallback? onBookAgain;
  final VoidCallback? onReportIssue;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    void addPrimary(String label, VoidCallback? onTap, {bool outline = false}) {
      if (onTap == null) return;
      actions.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: outline
                ? OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8507A),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      );
    }

    switch (lifecycle) {
      case BookingLifecycle.upcoming:
        addPrimary('View details', onViewDetails);
        if (canCancelBooking(booking)) {
          addPrimary('Cancel', onCancel, outline: true);
        }
        break;
      case BookingLifecycle.active:
        addPrimary('Open stay', onViewDetails);
        addPrimary('Contact host', onViewDetails, outline: true);
        break;
      case BookingLifecycle.pendingPayment:
        addPrimary('Pay now', onPay);
        addPrimary('Details', onViewDetails, outline: true);
        break;
      case BookingLifecycle.completed:
        addPrimary('Receipt', onViewDetails, outline: true);
        if (canReviewBooking(booking)) {
          addPrimary('Review', onReview, outline: true);
        }
        addPrimary('Book again', onBookAgain);
        break;
      case BookingLifecycle.cancelled:
      case BookingLifecycle.expired:
        addPrimary('Book again', onBookAgain);
        addPrimary('Details', onViewDetails, outline: true);
        break;
    }

    if (actions.isEmpty) {
      addPrimary('View details', onViewDetails);
    }

    return Row(children: actions.take(3).toList());
  }
}
