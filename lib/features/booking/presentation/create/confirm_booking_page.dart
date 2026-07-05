import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../navigation/app_routes.dart';

import '../../domain/entities/fee_breakdown.dart';
import 'bloc/booking_bloc.dart';
import 'bloc/booking_event.dart';
import 'bloc/booking_state.dart';

class ConfirmBookingPage extends StatelessWidget {
  const ConfirmBookingPage({super.key});

  // ── Date formatting helpers ────────────────────────────────────────────

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String _formatDate(DateTime d) =>
      '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Confirm booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: _blocListener,
        builder: (context, state) {
          if (state is BookingConfirmationReady) {
            return _buildBody(context, state);
          }

          if (state is BookingSubmitting) {
            // Keep showing the last confirmation state with a loading button.
            // The sticky bar handles the spinner internally.
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8507A)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Listener ───────────────────────────────────────────────────────────

  void _blocListener(BuildContext context, BookingState state) {
    if (state is BookingSuccess) {
      context.pushReplacement(AppRoutes.bookingSuccess, extra: state.booking);
    }

    if (state is BookingError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // ── Body ───────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, BookingConfirmationReady state) {
    final nights = state.checkOut.difference(state.checkIn).inDays;
    final isSubmitting =
        context.watch<BookingBloc>().state is BookingSubmitting;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Booking summary card ──
                _BookingSummaryCard(state: state, nights: nights),

                const SizedBox(height: 20),

                // ── Full fee breakdown ──
                _FullFeeBreakdownCard(feeBreakdown: state.feeBreakdown),

                const SizedBox(height: 24),

                // ── Payment method ──
                const _PaymentMethodSection(),

                const SizedBox(height: 24),

                // ── What happens next ──
                _WhatHappensNextCard(),

                const SizedBox(height: 16),

                // ── Cancellation policy ──
                _CancellationPolicyCard(checkIn: state.checkIn),

                const SizedBox(height: 100), // space for sticky bar
              ],
            ),
          ),
        ),

        // ── Sticky bottom bar ──
        _StickyBottomBar(
          totalDisplay: state.feeBreakdown.totalDisplay,
          isSubmitting: isSubmitting,
          onConfirmTap: () {
            context.read<BookingBloc>().add(const BookingConfirmRequested());
          },
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

// ── Booking Summary Card ─────────────────────────────────────────────────

class _BookingSummaryCard extends StatelessWidget {
  final BookingConfirmationReady state;
  final int nights;

  const _BookingSummaryCard({
    required this.state,
    required this.nights,
  });

  @override
  Widget build(BuildContext context) {
    final property = state.property;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Property row ──
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: property.photoUrls.isNotEmpty
                      ? property.photoUrls.first
                      : '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(Icons.image, color: Color(0xFF9CA3AF)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(Icons.broken_image,
                        color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${property.neighborhood}, ${property.city}'
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${property.nightlyRate.toInt()} MAD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFE8507A),
                          ),
                        ),
                        const Text(
                          '/night',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFF3F4F6), height: 1),
          ),

          // ── Dates row ──
          Row(
            children: [
              Expanded(
                child: _InfoCell(
                  label: 'CHECK-IN',
                  value: ConfirmBookingPage._formatDate(state.checkIn),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoCell(
                  label: 'CHECK-OUT',
                  value: ConfirmBookingPage._formatDate(state.checkOut),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Guests + nights row ──
          Row(
            children: [
              _PillChip(
                emoji: '👥',
                text:
                    '${state.guests} ${state.guests == 1 ? 'guest' : 'guests'}',
              ),
              const SizedBox(width: 8),
              _PillChip(
                emoji: '🌙',
                text: '$nights ${nights == 1 ? 'night' : 'nights'}',
              ),
            ],
          ),

          // ── Special requests ──
          if (state.specialRequests.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Special requests',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                border: Border.all(color: const Color(0xFFFDE68A)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                state.specialRequests,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String emoji;
  final String text;

  const _PillChip({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$emoji  $text',
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

// ── Full Fee Breakdown Card ──────────────────────────────────────────────

class _FullFeeBreakdownCard extends StatelessWidget {
  final FeeBreakdown feeBreakdown;

  const _FullFeeBreakdownCard({required this.feeBreakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price breakdown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          _FeeRow(
            label:
                '${feeBreakdown.nightlyRate.toInt()} MAD × ${feeBreakdown.nights} night${feeBreakdown.nights == 1 ? '' : 's'}',
            value: feeBreakdown.subtotalDisplay,
          ),
          if (feeBreakdown.hasDiscount) ...[
            const SizedBox(height: 8),
            _FeeRow(
              label: 'Discount',
              value: '-${feeBreakdown.totalDiscount.toInt()} MAD',
              valueColor: const Color(0xFF059669),
            ),
          ],
          const SizedBox(height: 8),
          _FeeRow(
            label: 'Service fee',
            value: feeBreakdown.guestFeeDisplay,
          ),
          const SizedBox(height: 8),
          _FeeRow(
            label: 'Host payout',
            value: feeBreakdown.hostPayoutDisplay,
            valueColor: const Color(0xFF9CA3AF),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          _FeeRow(
            label: 'Total',
            value: feeBreakdown.totalDisplay,
            isBold: true,
            valueColor: const Color(0xFFE8507A),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _FeeRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? const Color(0xFF1A1A2E) : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ??
                (isBold ? const Color(0xFF1A1A2E) : const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}

// ── What Happens Next Card ───────────────────────────────────────────────

class _WhatHappensNextCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ℹ️  What happens after confirming?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0369A1),
            ),
          ),
          const SizedBox(height: 12),
          ..._buildSteps(),
        ],
      ),
    );
  }

  List<Widget> _buildSteps() {
    const steps = [
      'Your booking is instantly confirmed.',
      'The exact address and check-in contact will be shared immediately on the next screen.',
      'You can manage your booking from My Bookings.',
    ];

    return steps.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key + 1}. ',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            Expanded(
              child: Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// ── Cancellation Policy Card ─────────────────────────────────────────────

class _CancellationPolicyCard extends StatelessWidget {
  final DateTime checkIn;

  const _CancellationPolicyCard({required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final freeCancelBy = checkIn.subtract(const Duration(hours: 24));
    final months = ConfirmBookingPage._months;
    final formatted =
        '${months[freeCancelBy.month - 1]} ${freeCancelBy.day}, ${freeCancelBy.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔖  Cancellation policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Free cancellation before $formatted. After that, the first night is non-refundable.',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky Bottom Bar ────────────────────────────────────────────────────

class _StickyBottomBar extends StatelessWidget {
  final String totalDisplay;
  final bool isSubmitting;
  final VoidCallback onConfirmTap;

  const _StickyBottomBar({
    required this.totalDisplay,
    required this.isSubmitting,
    required this.onConfirmTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: total price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                totalDisplay,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
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

          const SizedBox(width: 12),

          // Right: confirm button
          GestureDetector(
            onTap: isSubmitting ? null : onConfirmTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8507A), Color(0xFFD4145A)],
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8507A).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm & Pay →',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Method Section ───────────────────────────────────────────────

class _PaymentMethodSection extends StatefulWidget {
  const _PaymentMethodSection();

  @override
  State<_PaymentMethodSection> createState() => _PaymentMethodSectionState();
}

class _PaymentMethodSectionState extends State<_PaymentMethodSection> {
  String _selectedMethod = 'card';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pay with',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 14),
        _buildPaymentOption(
          id: 'card',
          title: 'Credit / Debit Card (CMI)',
          subtitle: 'Visa, Mastercard — secure payment via CMI',
          icon: Icons.credit_card,
          iconColor: const Color(0xFF374151),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8507A).withOpacity(0.1) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFFE8507A) : iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFD1D5DB),
                  width: isSelected ? 6.5 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
