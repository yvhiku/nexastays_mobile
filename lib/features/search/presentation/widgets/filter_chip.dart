import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable pill-shaped filter chip used on the home and search pages.
class NexaFilterChip extends StatelessWidget {
  const NexaFilterChip({
    super.key,
    required this.label,
    this.emoji,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String? emoji;
  final bool isActive;
  final VoidCallback onTap;

  static const double chipHeight = 36;

  static const TextHeightBehavior chipTextHeight = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  static const TextHeightBehavior _textHeight = chipTextHeight;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFE8507A);
    final inactiveText = const Color(0xFF6B7280);
    final inactiveEmoji = const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF0F5) : Colors.white,
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (emoji != null) ...[
              Text(
                emoji!,
                textHeightBehavior: _textHeight,
                style: TextStyle(
                  fontSize: 13,
                  height: 1,
                  color: isActive ? activeColor : inactiveEmoji,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              textHeightBehavior: _textHeight,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
