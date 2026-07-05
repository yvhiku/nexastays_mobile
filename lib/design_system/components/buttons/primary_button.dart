// =============================================================================
// NexaStays Design System — Primary Button
// =============================================================================

import 'package:flutter/material.dart';

import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The primary call-to-action button for NexaStays.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 52.0,
    this.radius = DSSpacing.borderRadius,
    this.leading,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;
  final double? height;
  final double? radius;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = loading;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius!),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(radius!),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius!),
              gradient: isDisabled ? null : DSColors.primaryGradient,
              color: isDisabled ? DSColors.neutral.withValues(alpha: 0.35) : null,
              boxShadow: isDisabled ? null : DSShadows.cardShadow,
            ),
            child: Center(child: _buildChild()),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (loading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }

    final textWidget = Text(
      label,
      textAlign: TextAlign.center,
      textHeightBehavior: DSTypography.centeredTextHeight,
      style: DSTypography.buttonLabel,
    );

    if (leading != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading!,
          const SizedBox(width: DSSpacing.s),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}
