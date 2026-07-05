import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../navigation/app_routes.dart';
import '../bloc/property_detail_state.dart';
import '../listing/listing_colors.dart';

class ListingBookingBar extends StatelessWidget {
  const ListingBookingBar({
    super.key,
    required this.state,
    required this.onSelectDates,
  });

  final PropertyDetailLoaded state;
  final VoidCallback onSelectDates;

  String _dateLabel() {
    final checkIn = state.selectedCheckIn;
    final checkOut = state.selectedCheckOut;
    if (checkIn != null && checkOut != null) {
      final fmt = DateFormat('MMM d');
      return '${fmt.format(checkIn)} – ${fmt.format(checkOut)}';
    }
    return 'Select dates';
  }

  @override
  Widget build(BuildContext context) {
    final hasDates =
        state.selectedCheckIn != null && state.selectedCheckOut != null;
    final price = hasDates && state.feePreview != null
        ? state.feePreview!.total.toInt()
        : state.property.nightlyRate.toInt();

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: ListingColors.surfaceBright.withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(
                color: ListingColors.outlineVariant.withValues(alpha: 0.1),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ListingColors.marginMobile,
            vertical: 16,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'MAD $price',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: ListingColors.onSurface,
                            ),
                          ),
                          Text(
                            hasDates ? '' : ' / night',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ListingColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onSelectDates,
                        child: Text(
                          _dateLabel(),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.05 * 12,
                            color: ListingColors.onSurfaceVariant,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      AppRoutes.booking,
                      extra: {
                        'propertyId': state.property.id,
                        'checkIn': state.selectedCheckIn,
                        'checkOut': state.selectedCheckOut,
                        'guests': state.selectedGuests,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ListingColors.primaryContainer,
                    foregroundColor: ListingColors.onPrimaryContainer,
                    elevation: 4,
                    shadowColor: ListingColors.primaryContainer.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Request to Book'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
