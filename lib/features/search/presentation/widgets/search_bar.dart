import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pill-shaped search bar for the NexaStays search screen.
///
/// Shows a placeholder when no filter is active, or the
/// [currentSummary] text when a search is in progress.
/// Tapping the bar fires [onTap]; the trailing "×" fires [onClear].
class NexaSearchBar extends StatelessWidget {
  const NexaSearchBar({
    super.key,
    required this.onTap,
    this.onClear,
    this.currentSummary,
  });

  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? currentSummary;

  bool get _hasValue =>
      currentSummary != null && currentSummary!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            // Search icon
            const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
            const SizedBox(width: 8),

            // Label / summary
            Expanded(
              child: Text(
                _hasValue ? currentSummary! : 'Marrakech, Casablanca...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _hasValue
                    ? GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      )
                    : GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
              ),
            ),

            // Clear button
            if (_hasValue && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
