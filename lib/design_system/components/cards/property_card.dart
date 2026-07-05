// =============================================================================
// NexaStays Design System — Property Card
// =============================================================================
// Standard card component used to display a listing in search results,
// home feeds, and saved lists. Includes a hero-animation tag for smooth
// transitions to the detail screen.
// =============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/price_formatter.dart';
import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A tappable card displaying a property's high-level details.
///
/// Features a 4:3 image, 'Verified' badge overlay for highly-rated stays,
/// and a structured info section at the bottom.
///
/// ```dart
/// PropertyCard(
///   id: '123',
///   title: 'Luxury Riad',
///   location: 'Marrakech, Morocco',
///   price: 150.0,
///   rating: 4.8,
///   imageUrl: 'https://...',
///   favorited: true,
///   onTap: () => _goToDetail('123'),
/// )
/// ```
class PropertyCard extends StatelessWidget {
  const PropertyCard({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.favorited = false,
    this.onTap,
    super.key,
  });

  /// Unique identifier passed to the [Hero] widget tag (`property-$id`).
  final String id;

  /// The name of the property.
  final String title;

  /// The geographic location (e.g., 'Marrakech, Morocco').
  final String location;

  /// The nightly rate.
  final double price;

  /// Average user rating out of 5.0. Stays > 4.5 get a 'Verified' badge.
  final double rating;

  /// URL or local asset path for the cover image.
  final String imageUrl;

  /// Whether this property is currently saved to the user's wishlist.
  final bool favorited;

  /// Callback triggered when the entire card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.surface,
        borderRadius: BorderRadius.circular(DSSpacing.borderRadius),
        boxShadow: DSShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSSpacing.borderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image Section (4:3) ───────────────────────────────────
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(DSSpacing.borderRadius),
                      ),
                      child: Hero(
                        tag: 'property-$id',
                        child: _buildImage(),
                      ),
                    ),
                  ),

                  // ── Verified Badge Overlay ────────────────────────────
                  if (rating > 4.5)
                    Positioned(
                      top: DSSpacing.m,
                      left: DSSpacing.m,
                      child: _VerifiedBadge(),
                    ),

                  // ── Favorite Icon Overlay ─────────────────────────────
                  Positioned(
                    top: DSSpacing.s,
                    right: DSSpacing.s,
                    child: IconButton(
                      icon: Icon(
                        favorited ? Icons.favorite : Icons.favorite_border,
                        color: favorited ? DSColors.primary : Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Fire favorite toggle event
                      },
                    ),
                  ),
                ],
              ),

              // ── Info Section ──────────────────────────────────────────
              Padding(
                padding: DSSpacing.paddingAllM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: DSTypography.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: DSSpacing.s),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: DSColors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: DSTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    Text(
                      location,
                      style: DSTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DSSpacing.s),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: PriceFormatter.format(price),
                            style: DSTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' / night',
                            style: DSTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles rendering either a network image ([CachedNetworkImage])
  /// or a local bundled asset depending on the prefix.
  Widget _buildImage() {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          AppAssets.placeholderProperty,
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          AppAssets.placeholderProperty,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppAssets.placeholderProperty,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}

// ── Private sub-widgets ─────────────────────────────────────────────────────

/// A small overlay badge showing "Verified" for highly-rated properties.
class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DSColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: DSShadows.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            color: DSColors.success,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: DSTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
