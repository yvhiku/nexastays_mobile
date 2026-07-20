import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/colors.dart';
import '../../domain/entities/reservation_snapshot.dart';

class BookingSummaryBar extends StatelessWidget {
  const BookingSummaryBar({
    required this.snapshot,
    this.counterpartName,
    super.key,
  });

  final ReservationSnapshot snapshot;
  final String? counterpartName;

  @override
  Widget build(BuildContext context) {
    final checkIn = DateTime.tryParse(snapshot.checkinDate);
    final checkOut = DateTime.tryParse(snapshot.checkoutDate);
    final dateFormat = DateFormat('MMM d');
    final datesLabel = checkIn != null && checkOut != null
        ? '${dateFormat.format(checkIn)} – ${dateFormat.format(checkOut)}'
        : '${snapshot.checkinDate} – ${snapshot.checkoutDate}';

    return Material(
      color: DSColors.primarySoft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: snapshot.primaryPhotoUrl != null
                  ? Image.network(
                      snapshot.primaryPhotoUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.listingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: DSColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    datesLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: DSColors.ink3,
                    ),
                  ),
                  if (counterpartName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      counterpartName!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: DSColors.ink4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (snapshot.bookingReference != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  snapshot.bookingReference!,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DSColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      color: DSColors.line,
      child: const Icon(Icons.home_outlined, color: DSColors.ink4),
    );
  }
}
