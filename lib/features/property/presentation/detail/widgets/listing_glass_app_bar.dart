import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../design_system/components/nexa_stays_wordmark.dart';
import '../listing/listing_colors.dart';class ListingGlassAppBar extends StatelessWidget {
  const ListingGlassAppBar({
    super.key,
    required this.onBack,
    this.onShare,
  });

  final VoidCallback onBack;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: ListingColors.surfaceBright.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ListingColors.marginMobile,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: onBack,
                  ),
                  const NexaStaysWordmark(fontSize: 22),                  _CircleIconButton(
                    icon: Icons.share_outlined,
                    onTap: onShare ?? () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: ListingColors.primary, size: 22),
        ),
      ),
    );
  }
}
