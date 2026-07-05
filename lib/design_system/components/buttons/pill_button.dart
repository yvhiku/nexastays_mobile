import 'package:flutter/material.dart';

import '../../tokens/typography.dart';

/// Compact pill-shaped CTA (gradient, solid, or muted disabled state).
class NexaPillButton extends StatelessWidget {
  const NexaPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.height = 48,
    this.fontSize = 15,
    this.expandWidth = true,
    this.gradient = const LinearGradient(
      colors: [Color(0xFFE8507A), Color(0xFFFF6B9D)],
    ),
    this.backgroundColor,
    this.textColor = Colors.white,
    this.disabledBackgroundColor = const Color(0xFFE5E7EB),
    this.disabledTextColor = const Color(0xFF9CA3AF),
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double height;
  final double fontSize;
  final bool expandWidth;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onTap != null;

    return SizedBox(
      width: expandWidth ? double.infinity : null,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(50),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: isEnabled &&
                      gradient != null &&
                      backgroundColor == null
                  ? gradient
                  : null,
              color: !isEnabled
                  ? disabledBackgroundColor
                  : backgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: expandWidth ? 24 : 18),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  textHeightBehavior: DSTypography.centeredTextHeight,
                  style: DSTypography.buttonLabel.copyWith(
                    fontSize: fontSize,
                    color: isEnabled ? textColor : disabledTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
