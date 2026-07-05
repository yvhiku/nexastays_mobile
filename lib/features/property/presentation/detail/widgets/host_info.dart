import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HostInfo extends StatelessWidget {
  const HostInfo({
    super.key,
    required this.hostId,
    required this.hostName,
    required this.hostPhotoUrl,
    required this.isVerifiedHost,
    required this.hostRating,
    required this.hostReviewCount,
    required this.hostType,
    required this.memberSince,
  });

  final String hostId;
  final String hostName;
  final String? hostPhotoUrl;
  final bool isVerifiedHost;
  final double hostRating;
  final int hostReviewCount;
  final String hostType;
  final String memberSince;

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
        Text(
          'Hosted by',
          style: GoogleFonts.playfairDisplay(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Host Profile Row ───────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFE8507A),
                        backgroundImage: hostPhotoUrl != null &&
                                hostPhotoUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(hostPhotoUrl!)
                            : null,
                        child: hostPhotoUrl == null || hostPhotoUrl!.isEmpty
                            ? Text(
                                _initials,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      if (isVerifiedHost)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.check,
                                  size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Host Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hostName,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verified Host · $memberSince',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${hostRating.toStringAsFixed(2)} · $hostReviewCount reviews',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),

              // ── Response Info Row ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Response rate: 98%',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  Text(
                    'Responds within: 1 hour',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),

              // ── Professional Host Banner ───────────────────────────────────
              if (hostType.toLowerCase() == 'portfolio' ||
                  hostType.toLowerCase() == 'hotel') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF0EA5E9), width: 3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.business_center_outlined,
                          size: 16, color: Color(0xFF0369A1)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a professional host managing multiple properties.',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0369A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
