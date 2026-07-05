import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../navigation/app_routes.dart';

import '../../../../design_system/components/badges/verified_badge.dart';
import '../../../property/domain/entities/property.dart';
import '../../domain/entities/fee_breakdown.dart';
import 'bloc/booking_bloc.dart';
import 'bloc/booking_event.dart';
import 'bloc/booking_state.dart';
import 'widgets/guest_verification_sheet.dart';

class BookingPage extends StatefulWidget {
  final String propertyId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;

  const BookingPage({
    required this.propertyId,
    this.checkIn,
    this.checkOut,
    this.guests,
    super.key,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(BookingInitialized(
          propertyId: widget.propertyId,
          preselectedCheckIn: widget.checkIn,
          preselectedCheckOut: widget.checkOut,
          preselectedGuests: widget.guests ?? 1,
        ));
  }

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
          'Book your stay',
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
          if (state is BookingInitial || state is BookingSubmitting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8507A)),
            );
          }

          if (state is BookingFormReady) {
            return _buildForm(context, state);
          }

          if (state is BookingError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFDC2626), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── BLoC listener ──────────────────────────────────────────────────────

  void _blocListener(BuildContext context, BookingState state) {
    if (state is BookingConfirmationReady) {
      context.push(AppRoutes.confirmBooking,
          extra: context.read<BookingBloc>());
    }

    if (state is BookingError) {
      if (!state.isDatesUnavailable) {
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
  }

  // ── Form body ──────────────────────────────────────────────────────────

  Widget _buildForm(BuildContext context, BookingFormReady state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Property summary card
                _PropertySummaryCard(property: state.property),
                const SizedBox(height: 20),

                // Date picker section
                const Text(
                  'Select dates',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerWidget(
                  checkIn: state.selectedCheckIn,
                  checkOut: state.selectedCheckOut,
                  blockedDates: state.blockedDates,
                  isCheckingAvail: state.isCheckingAvail,
                  onDatesSelected: (checkIn, checkOut) {
                    context.read<BookingBloc>().add(BookingDatesSelected(
                          checkIn: checkIn,
                          checkOut: checkOut,
                        ));
                  },
                ),
                if (!state.datesAvailable) ...[
                  const SizedBox(height: 10),
                  _DatesUnavailableBanner(),
                ],
                const SizedBox(height: 20),

                // Guest selector
                const Text(
                  'Guests',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                _GuestSelector(
                  count: state.selectedGuests,
                  maxGuests: state.property.maxGuests,
                  onChanged: (count) {
                    context
                        .read<BookingBloc>()
                        .add(BookingGuestsChanged(count: count));
                  },
                ),
                const SizedBox(height: 20),

                // Special requests
                const Text(
                  'Special requests (optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. late check-in, baby cot, quiet room',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8507A),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (text) {
                    context
                        .read<BookingBloc>()
                        .add(BookingSpecialRequestsChanged(text: text));
                  },
                ),
                const SizedBox(height: 20),

                // Fee breakdown card
                if (state.feeBreakdown != null)
                  _FeeBreakdownCard(feeBreakdown: state.feeBreakdown!),

                const SizedBox(height: 100), // bottom padding for sticky bar
              ],
            ),
          ),
        ),

        // Sticky bottom bar
        _StickyBottomBar(
          feeBreakdown: state.feeBreakdown,
          isLoading: state.isCheckingAvail,
          onReviewTap: state.feeBreakdown != null && state.datesAvailable
              ? () => _openGuestVerification(context, state)
              : null,
        ),
      ],
    );
  }

  Future<void> _openGuestVerification(
    BuildContext context,
    BookingFormReady state,
  ) async {
    final occupants = await showGuestVerificationSheet(
      context: context,
      guestCount: state.selectedGuests,
    );
    if (occupants == null || !context.mounted) return;

    context.read<BookingBloc>().add(BookingSubmitRequested(
          propertyId: state.property.id,
          guestId: '',
          occupants: occupants,
        ));
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

// ── Property Summary Card ────────────────────────────────────────────────

class _PropertySummaryCard extends StatelessWidget {
  final Property property;

  const _PropertySummaryCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Property photo
          CachedNetworkImage(
            imageUrl:
                property.photoUrls.isNotEmpty ? property.photoUrls.first : '',
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 90,
              height: 90,
              color: const Color(0xFFE5E7EB),
              child: const Icon(Icons.image, color: Color(0xFF9CA3AF)),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 90,
              height: 90,
              color: const Color(0xFFE5E7EB),
              child: const Icon(Icons.broken_image, color: Color(0xFF9CA3AF)),
            ),
          ),

          // Property info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${property.neighborhood}, ${property.city}'.toUpperCase(),
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
                      if (property.isVerified) ...[
                        const SizedBox(width: 8),
                        const VerifiedBadge(size: 14, compact: true),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date Picker Widget ───────────────────────────────────────────────────

class _DatePickerWidget extends StatelessWidget {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final List<DateTime> blockedDates;
  final bool isCheckingAvail;
  final void Function(DateTime checkIn, DateTime checkOut) onDatesSelected;

  const _DatePickerWidget({
    required this.checkIn,
    required this.checkOut,
    required this.blockedDates,
    required this.isCheckingAvail,
    required this.onDatesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DateTile(
                label: 'Check-in',
                date: checkIn,
                icon: Icons.calendar_today_outlined,
                onTap: () => _pickDateRange(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateTile(
                label: 'Check-out',
                date: checkOut,
                icon: Icons.calendar_today_outlined,
                onTap: () => _pickDateRange(context),
              ),
            ),
          ],
        ),
        if (isCheckingAvail) ...[
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE8507A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Checking availability…',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: checkIn != null && checkOut != null
          ? DateTimeRange(start: checkIn!, end: checkOut!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8507A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A2E),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE8507A),
              ),
            ),
          ),
          child: child!,
        );
      },
      selectableDayPredicate: (day, start, end) {
        return !blockedDates.any((blocked) =>
            blocked.year == day.year &&
            blocked.month == day.month &&
            blocked.day == day.day);
      },
    );

    if (result != null) {
      onDatesSelected(result.start, result.end);
    }
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date != null
                      ? '${months[date!.month - 1]} ${date!.day}, ${date!.year}'
                      : 'Select',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: date != null
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dates Unavailable Banner ─────────────────────────────────────────────

class _DatesUnavailableBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Text('⚠️', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'These dates are no longer available. Please select others.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest Selector ───────────────────────────────────────────────────────

class _GuestSelector extends StatelessWidget {
  final int count;
  final int maxGuests;
  final ValueChanged<int> onChanged;

  const _GuestSelector({
    required this.count,
    required this.maxGuests,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count ${count == 1 ? 'guest' : 'guests'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'Max $maxGuests',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _CircleButton(
                icon: Icons.remove,
                enabled: count > 1,
                onTap: () => onChanged(count - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              _CircleButton(
                icon: Icons.add,
                enabled: count < maxGuests,
                onTap: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
          border: Border.all(
            color: enabled ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF1A1A2E) : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}

// ── Fee Breakdown Card ───────────────────────────────────────────────────

class _FeeBreakdownCard extends StatelessWidget {
  final FeeBreakdown feeBreakdown;

  const _FeeBreakdownCard({required this.feeBreakdown});

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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), height: 1),
          ),
          _FeeRow(
            label: 'Total',
            value: feeBreakdown.totalDisplay,
            isBold: true,
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

// ── Sticky Bottom Bar ────────────────────────────────────────────────────

class _StickyBottomBar extends StatelessWidget {
  final FeeBreakdown? feeBreakdown;
  final bool isLoading;
  final VoidCallback? onReviewTap;

  const _StickyBottomBar({
    required this.feeBreakdown,
    required this.isLoading,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
        ),
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
          // Left: price info
          Expanded(
            child: feeBreakdown != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        feeBreakdown!.totalDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFFE8507A),
                        ),
                      ),
                      Text(
                        'total · ${feeBreakdown!.nights} night${feeBreakdown!.nights == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'Select dates to see price',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          // Right: review button
          AnimatedOpacity(
            opacity: onReviewTap != null ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: onReviewTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8507A), Color(0xFFD4145A)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: onReviewTap != null
                      ? [
                          const BoxShadow(
                            color: Color(0x40E8185E),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Review booking →',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
