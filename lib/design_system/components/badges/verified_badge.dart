// =============================================================================
// NexaStays Design System — Verified Badge
// =============================================================================
// A standardized badge indicating high trust or a highly-rated property.
// Mostly used as an overlay on property images or next to titles.
// =============================================================================

import 'package:flutter/material.dart';

import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/typography.dart';

/// A badge indicating a verified or highly-trusted property.
///
/// Can be displayed in a full rectangular format with text, or a [compact]
/// circular icon-only format for tight spaces.
///
/// ```dart
/// // Overlay usage in PropertyCard
/// Positioned(
///   top: DSSpacing.m,
///   left: DSSpacing.m,
///   child: const VerifiedBadge(compact: false),
/// )
/// ```
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    this.size = 20.0,
    this.compact = false,
    super.key,
  });

  /// The dimension of the checkmark icon circle. Adjusts internal padding proportionately.
  /// Defaults to `20.0`.
  final double size;

  /// If `true`, hides the 'Verified' text and rectangular background, showing
  /// only the floating green checkmark circle.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Shared icon: White check inside a Success (Green) circle
    final iconCircle = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: DSColors.success,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: size *
              0.7, // Scale the checkmark slightly smaller than the circle
        ),
      ),
    );

    if (compact) {
      // In compact mode, we just float the green circle with a shadow
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: DSShadows.cardShadow,
        ),
        child: iconCircle,
      );
    }

    // Expanded mode: Rounded white background floating with a shadow
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.4,
        vertical: size * 0.2, // ~ 8px horizontal, 4px vertical for size 20
      ),
      decoration: BoxDecoration(
        color: DSColors.surface.withValues(alpha: 0.95), // Solid white surface
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: DSShadows.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconCircle,
          SizedBox(width: size * 0.25),
          Text(
            'Verified',
            style: DSTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}
