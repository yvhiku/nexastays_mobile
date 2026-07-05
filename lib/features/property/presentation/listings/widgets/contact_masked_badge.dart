import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ContactBadgeState { masked, revealed }

class ContactMaskedBadge extends StatelessWidget {
  const ContactMaskedBadge({
    super.key,
    this.state = ContactBadgeState.masked,
  });

  /// The current visibility state of the host contact details.
  final ContactBadgeState state;

  @override
  Widget build(BuildContext context) {
    // Styling mapped entirely by the enum state
    final isMasked = state == ContactBadgeState.masked;

    final Color bgColor =
        isMasked ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4); // Amber 50 vs Green 50
    final Color textColor =
        isMasked ? const Color(0xFF92400E) : const Color(0xFF15803D); // Amber 800 vs Green 700
    final Color iconColor =
        isMasked ? const Color(0xFFD97706) : const Color(0xFF16A34A); // Amber 600 vs Green 600

    final IconData iconData = isMasked ? Icons.lock_outline : Icons.check;
    final String labelText =
        isMasked ? 'Contact masked until confirmed' : 'Contact shared';

    return Container(
      // Fits purely to the content's intrinsic width + padding
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 12,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            labelText,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
