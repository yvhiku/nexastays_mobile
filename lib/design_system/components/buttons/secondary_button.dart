// =============================================================================
// NexaStays Design System — Secondary Button
// =============================================================================
// Outlined button used for secondary actions (e.g., 'Cancel', 'Skip', or
// 'Learn More'). Features a white background, primary border, and soft shadow.
// =============================================================================

import 'package:flutter/material.dart';


import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// An outlined button for secondary actions.
///
/// Features a primary-colored border, white background, and slightly darker
/// text for legibility. Includes a soft shadow to match the overall depth
/// of the component library.
///
/// ```dart
/// SecondaryButton(
///   label: 'Cancel',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 52.0,
    this.radius = DSSpacing.borderRadius,
    this.leading,
    super.key,
  });

  /// The text displayed on the button.
  final String label;

  /// The callback triggered when the button is tapped.
  /// Disabled automatically if [loading] is `true`.
  final VoidCallback? onPressed;

  /// If `true`, replaces the label with a progress spinner and disables taps.
  final bool loading;

  /// The fixed height of the button. Defaults to `52.0`.
  final double? height;

  /// The corner radius. Defaults to [DSSpacing.borderRadius] (`12.0`).
  final double? radius;

  /// Optional widget (usually an `Icon`) drawn before the label.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    // Determine interactive state.
    final isDisabled = loading || onPressed == null;

    final disabledColor = DSColors.neutral.withOpacity(0.3);
    final borderColor = isDisabled ? disabledColor : DSColors.primary;
    final textColor = isDisabled ? disabledColor : DSColors.primaryDark;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: label,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: DSColors.surface, // always white background
          borderRadius: BorderRadius.circular(radius!),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: DSShadows.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius:
                BorderRadius.circular(radius! - 1.5), // account for border
            child: Center(
              child: _buildChild(textColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color contentColor) {
    if (loading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: DSColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    final textWidget = Text(
      label,
      textAlign: TextAlign.center,
      textHeightBehavior: DSTypography.centeredTextHeight,
      style: DSTypography.buttonLabel.copyWith(
        color: contentColor,
      ),
    );

    if (leading != null) {
      // If the leading widget is an Icon without explicit color,
      // it will inherit the default icon theme length, but we can
      // wrap it in an IconTheme to force the primaryDark color to match text.
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: contentColor, size: 20),
            child: leading!,
          ),
          const SizedBox(width: DSSpacing.s),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}
