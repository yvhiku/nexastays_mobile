// =============================================================================
// NexaStays Design System — Input Field
// =============================================================================
// Reusable wrapper around [TextFormField] ensuring consistent padding,
// borders, colors, and typography across all forms in the app.
// =============================================================================

import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A standard text input field for NexaStays forms.
///
/// Ensures consistent label spacing, error text styling, and focus states.
/// By default, the background is [DSColors.surface] with a muted border.
///
/// ```dart
/// DSInputField(
///   controller: _emailController,
///   label: 'Email address',
///   hint: 'Enter your email',
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: Icons.email_outlined,
///   validator: Validators.validateEmail,
/// )
/// ```
class DSInputField extends StatelessWidget {
  const DSInputField({
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    super.key,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// Optional text displayed above the input field.
  final String? label;

  /// Placeholder text shown inside the field when empty.
  final String? hint;

  /// Whether to hide the text (e.g., for passwords).
  final bool obscureText;

  /// The type of keyboard to use.
  final TextInputType keyboardType;

  /// The action button on the keyboard (e.g., Next, Done).
  final TextInputAction textInputAction;

  /// Called to validate the input. Returns an error string or `null`.
  final String? Function(String?)? validator;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates they are done editing the text in the field.
  final ValueChanged<String>? onFieldSubmitted;

  /// An icon displayed before the input text.
  final IconData? prefixIcon;

  /// An optional widget displayed after the input text (e.g. an obscure toggle).
  final Widget? suffix;

  /// The maximum number of lines the field can span. Defaults to 1.
  /// Must be 1 if [obscureText] is true.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: DSTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: DSColors.neutral,
            ),
          ),
          const SizedBox(height: DSSpacing.s),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          style: DSTypography.bodyLarge,
          cursorColor: DSColors.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: DSColors.surface,
            hintText: hint,
            hintStyle: DSTypography.bodySmall,
            contentPadding: DSSpacing.paddingAllM,

            // ── Prefix icon ───────────────────────────────────────────
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: DSColors.neutral.withValues(alpha: 0.5),
                    size: 20,
                  )
                : null,

            // ── Suffix widget ─────────────────────────────────────────
            suffixIcon: suffix,

            // ── Borders ───────────────────────────────────────────────
            border: _buildBorder(DSColors.muted, width: 1.0),
            enabledBorder: _buildBorder(DSColors.muted, width: 1.0),
            focusedBorder: _buildBorder(DSColors.primary, width: 1.5),
            errorBorder: _buildBorder(DSColors.danger, width: 1.0),
            focusedErrorBorder: _buildBorder(DSColors.danger, width: 1.5),

            // ── Error text styling ────────────────────────────────────
            errorStyle: DSTypography.caption.copyWith(
              color: DSColors.danger,
              height: 1.0,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  /// Helper to dry up border definitions.
  OutlineInputBorder _buildBorder(Color color, {required double width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSSpacing.borderRadius),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}
