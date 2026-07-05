import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';

class AuthHeader extends StatelessWidget {
  final String? icon;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;
  final bool showBack;
  final bool showSkip;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const AuthHeader({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.showSkip = false,
    this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBack || showSkip)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: Row(
              children: [
                if (showBack)
                  GestureDetector(
                    onTap: onBack ?? () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 18, color: DSColors.ink),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                if (showSkip)
                  GestureDetector(
                    onTap: onSkip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: DSColors.primary,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),

        const SizedBox(height: 16),

        if (iconWidget != null || icon != null)
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 32),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFDF1F2),
            ),
            child: Center(
              child: iconWidget ??
                  Text(
                    icon!,
                    style: const TextStyle(fontSize: 30),
                  ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
        ),

        if (subtitle != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 36),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
