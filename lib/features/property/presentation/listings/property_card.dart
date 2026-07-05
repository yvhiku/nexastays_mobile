import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../navigation/app_routes.dart';
import '../../domain/entities/property.dart';


/// A horizontal card showing a property listing with image, details,
/// price, save button, and masked-contact badge.
class PropertyListCard extends StatelessWidget {
  const PropertyListCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isSaved = false,
    this.onSaveToggle,
    this.buttonText = 'View',
  });

  final Property property;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onSaveToggle;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 146,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Image ─────────────────────────────────────────
            SizedBox(
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: property.photoUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: property.photoUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: const Color(0xFFF3F4F6),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFFF3F4F6),
                              child: const Icon(Icons.home,
                                  size: 32, color: Color(0xFF9CA3AF)),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(Icons.home,
                                size: 32, color: Color(0xFF9CA3AF)),
                          ),
                  ),
                  // Badges
                  if (property.isTrending || property.isVerified)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: property.isTrending
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFE8507A),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          property.isTrending ? '🔥' : '✓',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Right: Details ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // location label
                    Text(
                      property.cityNeighborhood.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Name
                    Text(
                      property.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Description / Subtitle
                    Text(
                      property.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Price + View button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: NumberFormat('#,##0').format(property.nightlyRate),
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE8507A),
                                  ),
                                ),
                                TextSpan(
                                  text: ' MAD/night',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.propertyDetailOf(property.id)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8507A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              buttonText,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Masked-contact badge
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Text('🔒', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 4),
                            Text(
                              'Contact masked until confirmed',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
