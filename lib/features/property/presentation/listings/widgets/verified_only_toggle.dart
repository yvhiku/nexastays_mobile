import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifiedOnlyToggle extends StatelessWidget {
  const VerifiedOnlyToggle({
    super.key,
    required this.value,
    required this.verifiedCount,
    required this.onChanged,
  });

  final bool value;
  final int verifiedCount;
  final ValueChanged<bool> onChanged;

  static const _accent = Color(0xFFE8507A);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Main Toggle Card ───────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: value ? const Color(0xFFFFF0F5) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value ? const Color(0xFFFFB3C1) : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Shield icon
              Icon(
                Icons.security_rounded,
                color: value ? _accent : const Color(0xFF9CA3AF),
                size: 18,
              ),
              const SizedBox(width: 8),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified walkthroughs only',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Properties with recorded video tours',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Switch
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeColor: _accent,
                trackColor: const Color(0xFFE5E7EB),
              ),
            ],
          ),
        ),

        // ── Active state badge ─────────────────────────────────────
        if (value)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '✓ Showing $verifiedCount verified properties',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
