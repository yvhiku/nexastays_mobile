import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../listing/listing_colors.dart';

class ListingImageCarousel extends StatefulWidget {
  const ListingImageCarousel({
    super.key,
    required this.photoUrls,
    required this.isVerified,
    required this.isGuestFavorite,
    required this.isSaved,
    required this.onFavoriteTap,
  });

  final List<String> photoUrls;
  final bool isVerified;
  final bool isGuestFavorite;
  final bool isSaved;
  final VoidCallback onFavoriteTap;

  @override
  State<ListingImageCarousel> createState() => _ListingImageCarouselState();
}

class _ListingImageCarouselState extends State<ListingImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photoUrls;

    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photos.isEmpty)
            Container(color: ListingColors.surfaceContainerHighest)
          else
            PageView.builder(
              controller: _pageController,
              itemCount: photos.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: photos[index],
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: ListingColors.surfaceContainerHighest),
                  errorWidget: (_, __, ___) => Container(
                    color: ListingColors.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported),
                  ),
                );
              },
            ),

          // Overlay badges
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isVerified) ...[
                  _OverlayBadge(
                    label: 'Verified Property',
                    icon: Icons.verified,
                    backgroundColor:
                        ListingColors.tertiaryContainer.withValues(alpha: 0.9),
                    foregroundColor: ListingColors.onTertiaryContainer,
                    filledIcon: true,
                  ),
                  const SizedBox(height: 8),
                ],
                if (widget.isGuestFavorite)
                  _OverlayBadge(
                    label: 'Guest Favorite',
                    icon: Icons.star,
                    backgroundColor:
                        ListingColors.surfaceBright.withValues(alpha: 0.9),
                    foregroundColor: ListingColors.primary,
                    filledIcon: true,
                  ),
              ],
            ),
          ),

          // Favorite button
          Positioned(
            top: 16,
            right: 16,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: InkWell(
                    onTap: widget.onFavoriteTap,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        widget.isSaved ? Icons.favorite : Icons.favorite_border,
                        color: widget.isSaved ? Colors.red : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dots
          if (photos.isNotEmpty)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(photos.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: isActive ? 1 : 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.filledIcon = false,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool filledIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: backgroundColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: foregroundColor,
                fill: filledIcon ? 1.0 : 0.0,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05 * 12,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
