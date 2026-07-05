import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ListingStatus { live, paused, underReview, rejected, draft }

class ListingStatusBadge extends StatelessWidget {
  const ListingStatusBadge({
    super.key,
    required this.status,
  });

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    String label;

    switch (status) {
      case ListingStatus.live:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        textColor = const Color(0xFF16A34A);
        label = '✓ Live';
        break;
      case ListingStatus.paused:
        bgColor = const Color(0xFFFFF7ED);
        borderColor = const Color(0xFFFED7AA);
        textColor = const Color(0xFFEA580C);
        label = '⏸ Paused';
        break;
      case ListingStatus.underReview:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFFD97706);
        label = '⏳ Under Review';
        break;
      case ListingStatus.rejected:
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        textColor = const Color(0xFFDC2626);
        label = '✗ Rejected';
        break;
      case ListingStatus.draft:
        bgColor = const Color(0xFFF3F4F6);
        borderColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
        label = '✏ Draft';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
