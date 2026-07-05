import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../listing/listing_colors.dart';

class ListingHostSection extends StatelessWidget {
  const ListingHostSection({
    super.key,
    required this.hostName,
    this.hostPhotoUrl,
    required this.isVerifiedHost,
    required this.isSuperhost,
    this.hostQuote,
    this.onContactHost,
  });

  final String hostName;
  final String? hostPhotoUrl;
  final bool isVerifiedHost;
  final bool isSuperhost;
  final String? hostQuote;
  final VoidCallback? onContactHost;

  String get _initials {
    if (hostName.isEmpty) return '?';
    final parts = hostName.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return hostName.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: ListingColors.primaryContainer,
                  backgroundImage: hostPhotoUrl != null && hostPhotoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(hostPhotoUrl!)
                      : null,
                  child: hostPhotoUrl == null || hostPhotoUrl!.isEmpty
                      ? Text(
                          _initials,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ListingColors.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                if (isVerifiedHost)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: ListingColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ListingColors.surfaceBright,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        size: 14,
                        color: Colors.white,
                        fill: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hosted by $hostName',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ListingColors.onSurface,
                    ),
                  ),
                  if (isSuperhost) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SUPERHOST',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05 * 12,
                        color: ListingColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ListingColors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hostQuote != null && hostQuote!.isNotEmpty) ...[
                Text(
                  '"$hostQuote"',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: ListingColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              OutlinedButton(
                onPressed: onContactHost,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ListingColors.primary,
                  backgroundColor: ListingColors.surfaceBright,
                  side: const BorderSide(color: ListingColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Contact Host'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
