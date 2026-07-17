import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../navigation/app_routes.dart';
import '../../../home/domain/entities/property.dart';
import '../../../property/presentation/widgets/stay_card.dart';

class ExploreMap extends StatefulWidget {
  const ExploreMap({super.key, required this.properties});

  final List<Property> properties;

  @override
  State<ExploreMap> createState() => _ExploreMapState();
}

class _ExploreMapState extends State<ExploreMap> {
  final _mapController = MapController();

  List<Property> get _mappable => widget.properties
      .where((property) => property.hasMapCoordinates)
      .toList();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showPreview(Property property) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: StayCard(
            stay: StayCardData.fromHomeProperty(property),
            compact: true,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.propertyDetailOf(property.id));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_mappable.isEmpty) {
      return const _MapMessage(
        icon: Icons.location_off_outlined,
        title: 'No stays to map yet',
        message: 'These results do not have map coordinates. Try List view.',
      );
    }

    final first = _mappable.first;
    final center = LatLng(first.latitude!, first.longitude!);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: _mappable.length == 1 ? 12 : 7,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.nexa_stays_f',
            ),
            MarkerLayer(
              markers: [
                for (final property in _mappable)
                  Marker(
                    point: LatLng(property.latitude!, property.longitude!),
                    width: 96,
                    height: 40,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => _showPreview(property),
                      child: _PriceBubble(
                        label: '${property.pricePerNight.round()} MAD',
                      ),
                    ),
                  ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Positioned(
          top: 12,
          left: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '${_mappable.length} of ${widget.properties.length} stays on map',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceBubble extends StatelessWidget {
  const _PriceBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: const Color(0xFFE8507A)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
