import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/property.dart';

class LocationRevealCard extends StatelessWidget {
  const LocationRevealCard({
    super.key,
    required this.property,
    required this.contactRevealed,
  });

  final Property property;
  final bool contactRevealed;

  Future<void> _launchPhone(String phone) async {
    // url_launcher package is not installed in pubspec.yaml
    debugPrint('Launching phone app to call: $phone');
  }

  @override
  Widget build(BuildContext context) {
    if (contactRevealed) {
      return _buildRevealedState(context);
    } else {
      return _buildMaskedState(context);
    }
  }

  Widget _buildMaskedState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property.maskedAddress,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Static Map Placeholder ──────────────────────────────
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulating a blurred map background
                Opacity(
                  opacity: 0.3,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 15,
                    ),
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: index % 3 == 0 ? Colors.grey : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Lock Card Overlay
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, size: 14, color: Color(0xFF1A1A2E)),
                          const SizedBox(width: 6),
                          Text(
                            'Exact address shared after booking',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
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
          const SizedBox(height: 10),

          // ── Info Text ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📍', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'The exact address and check-in contact will be shared immediately after your booking is confirmed.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────
          Row(
            children: [
              const CircleAvatar(
                radius: 10,
                backgroundColor: Color(0xFF16A34A),
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Location confirmed',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Full Address ────────────────────────────────────────
          Text(
            property.exactAddress,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

          // ── Map preview ─────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: property.hasMapCoordinates
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          property.latitude!,
                          property.longitude!,
                        ),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.nexa_stays_f',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                property.latitude!,
                                property.longitude!,
                              ),
                              width: 36,
                              height: 36,
                              alignment: Alignment.bottomCenter,
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFFE8507A),
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      color: const Color(0xFFE5E7EB),
                      child: const Center(
                        child: Icon(
                          Icons.map_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 36,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Check-in Contact Card ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.phone_in_talk, color: Color(0xFF16A34A), size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in contact',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        // Note: Using checkInContact instead of missing 'contactName'
                        Text(
                          property.checkInContact,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => _launchPhone(property.checkInContact),
                          child: Text(
                            property.checkInContact, // Can be improved if phone/name separated
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: const Color(0xFFE8507A),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFFE8507A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (property.checkInInstructions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),
                  Text(
                    property.checkInInstructions,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
