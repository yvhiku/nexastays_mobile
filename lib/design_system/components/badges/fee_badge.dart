// =============================================================================
// NexaStays Design System — Fee Badge
// =============================================================================
// A subtle pill-shaped badge used to highlight pricing breakdowns
// or discount labels. Includes native Tooltip support.
// =============================================================================

import 'package:flutter/material.dart';

import '../../tokens/colors.dart';
import '../../tokens/typography.dart';

/// A small contextual badge used alongside pricing information.
///
/// Wraps text in a pill shape with a [DSColors.muted] background and subtle
/// border. Optionally displays a native Material [Tooltip] on long-press or hover.
///
/// ```dart
/// FeeBadge(
///   text: 'Includes taxes and fees',
///   tooltip: 'City tax 8%, Service fee 12%',
/// )
/// ```
class FeeBadge extends StatelessWidget {
  const FeeBadge({
    required this.text,
    this.tooltip,
    this.color,
    super.key,
  });

  /// The short label displayed inside the badge.
  final String text;

  /// Optional expanded description shown to the user on hover or long-press.
  final String? tooltip;

  /// Override the default [DSColors.neutral] text color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DSTypography.caption.copyWith(
      color: color ?? DSColors.neutral.withValues(alpha: 0.8),
      fontWeight: FontWeight.w500,
    );

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: DSColors.muted,
        borderRadius: BorderRadius.circular(16.0), // Classic pill shape
        border: Border.all(
          color: DSColors.neutral.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: defaultTextStyle,
      ),
    );

    // If no tooltip is provided, just return the pill natively.
    if (tooltip == null || tooltip!.isEmpty) {
      return badge;
    }

    return Tooltip(
      message: tooltip!,
      // Styling the tooltip to match the design system tightly:
      decoration: BoxDecoration(
        color: DSColors.neutral.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6.0),
      ),
      textStyle: DSTypography.caption.copyWith(
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: badge,
    );
  }
}
