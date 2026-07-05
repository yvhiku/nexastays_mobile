// =============================================================================
// NexaStays Design System — Booking Card
// =============================================================================
// Displays a summary of a user's booking (past, present, or future).
// Includes a horizontal layout with a thumbnail, status badge, and actions.
// =============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/price_formatter.dart';
import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../buttons/secondary_button.dart';

/// The status of a given booking.
enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  completed,
  active,
  rejected,
}

/// A card summarising a trip/booking.
///
/// Features a left-aligned thumbnail and right-aligned details, including
/// a dynamic status chip and optional action buttons (e.g., Cancel, View).
///
/// ```dart
/// BookingCard(
///   bookingId: 'B-123',
///   propertyTitle: 'Oasis Villa',
///   dates: '24 Jun - 28 Jun',
///   totalPrice: 450.0,
///   status: BookingStatus.confirmed,
///   imageUrl: 'https://...',
///   onTap: () => _goToBookingDetail('B-123'),
///   onCancel: () => _showCancelDialog(),
/// )
/// ```
class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.bookingId,
    required this.propertyTitle,
    required this.dates,
    required this.totalPrice,
    required this.status,
    required this.imageUrl,
    this.onTap,
    this.onCancel,
    super.key,
  });

  /// The unique reference for the booking.
  final String bookingId;

  /// Name of the property.
  final String propertyTitle;

  /// Formatted date range string.
  final String dates;

  /// The total price of the stay including fees and taxes.
  final double totalPrice;

  /// The current state of the trip.
  final BookingStatus status;

  /// URL or local asset path for the property thumbnail.
  final String imageUrl;

  /// Callback when the card is tapped (usually navigates to detail).
  final VoidCallback? onTap;

  /// Optional callback to cancel the booking. If null, the cancel button is hidden.
  final VoidCallback? onCancel;

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
          child: Padding(
            padding: DSSpacing.paddingAllM,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thumbnail ───────────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildImage(),
                  ),
                ),
                const SizedBox(width: DSSpacing.m),

                // ── Details Column ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              propertyTitle,
                              style:
                                  DSTypography.heading3.copyWith(fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.xs),
                      Text(
                        dates,
                        style: DSTypography.bodySmall,
                      ),
                      const SizedBox(height: DSSpacing.s),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price info
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 16,
                                color: DSColors.neutral.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                PriceFormatter.format(totalPrice),
                                style: DSTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          // Cancel Button (if applicable)
                          if (onCancel != null &&
                              (status == BookingStatus.confirmed ||
                                  status == BookingStatus.pending))
                            SizedBox(
                              height: 32,
                              child: SecondaryButton(
                                label: 'Cancel',
                                height: 32,
                                radius: 8,
                                onPressed: onCancel,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Resolves the image source (local vs network).
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

/// A small, color-coded chip indicating the booking state.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.completed:
        backgroundColor = DSColors.success.withValues(alpha: 0.1);
        textColor = DSColors.success;
        label = status == BookingStatus.confirmed ? 'Confirmed' : 'Completed';
        break;
      case BookingStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange.shade800;
        label = 'Pending';
        break;
      case BookingStatus.cancelled:
        backgroundColor = DSColors.danger.withValues(alpha: 0.1);
        textColor = DSColors.danger;
        label = 'Cancelled';
        break;
      case BookingStatus.active:
        // TODO: Handle this case.
        throw UnimplementedError();
      case BookingStatus.rejected:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: DSTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
