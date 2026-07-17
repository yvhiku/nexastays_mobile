import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/property.dart';
import '../listing/listing_colors.dart';

class ListingLocationSection extends StatefulWidget {
  const ListingLocationSection({super.key, required this.property});

  final Property property;

  @override
  State<ListingLocationSection> createState() => _ListingLocationSectionState();
}

class _ListingLocationSectionState extends State<ListingLocationSection> {
  LatLng? _center;
  bool _loading = true;
  bool _failed = false;

  Property get property => widget.property;

  @override
  void initState() {
    super.initState();
    _resolveCenter();
  }

  @override
  void didUpdateWidget(covariant ListingLocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.id != property.id ||
        oldWidget.property.latitude != property.latitude ||
        oldWidget.property.longitude != property.longitude ||
        oldWidget.property.exactAddress != property.exactAddress) {
      _resolveCenter();
    }
  }

  Future<void> _resolveCenter() async {
    setState(() {
      _loading = true;
      _failed = false;
    });

    if (property.hasMapCoordinates) {
      setState(() {
        _center = LatLng(property.latitude!, property.longitude!);
        _loading = false;
      });
      return;
    }

    final query = property.fullMapsSearchQuery.trim();
    if (query.isEmpty || query.toLowerCase() == 'morocco') {
      setState(() {
        _center = null;
        _loading = false;
        _failed = true;
      });
      return;
    }

    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'NexaStays/1.0 (listing-detail-map)',
          },
        ),
      );
      final response = await dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 1,
          'countrycodes': 'ma',
        },
      );
      if (!mounted) return;
      final results = response.data;
      if (results == null || results.isEmpty) {
        setState(() {
          _center = null;
          _loading = false;
          _failed = true;
        });
        return;
      }
      final first = results.first as Map<String, dynamic>;
      setState(() {
        _center = LatLng(
          double.parse(first['lat'] as String),
          double.parse(first['lon'] as String),
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _center = null;
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _openInMaps() async {
    final Uri uri;
    if (property.hasMapCoordinates) {
      final lat = property.latitude!;
      final lng = property.longitude!;
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else {
      final query = property.fullMapsSearchQuery;
      if (query.isEmpty) return;
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
      );
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationText = property.displayAddress;
    final hasCoords = property.hasMapCoordinates;
    final hasArea = property.shortLocationLabel.isNotEmpty;
    final hasAddress = locationText.trim().isNotEmpty &&
        locationText.toLowerCase() != 'morocco';

    if (!hasAddress && !hasCoords && !hasArea) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where you\'ll stay',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ListingColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: ListingColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                locationText,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: ListingColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (hasCoords || hasAddress || hasArea) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: _buildMap(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openInMaps,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Open in Maps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ListingColors.primary,
                side: const BorderSide(color: ListingColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check-in contact and access instructions are shared after your booking is confirmed.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: ListingColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMap() {
    if (_loading) {
      return Container(
        color: const Color(0xFFFCEEF2),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_failed || _center == null) {
      return Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: Icon(Icons.map_outlined, color: Color(0xFF9CA3AF), size: 40),
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _center!,
        initialZoom: property.hasMapCoordinates ? 15 : 13,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.nexa_stays_f',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _center!,
              width: 40,
              height: 40,
              alignment: Alignment.bottomCenter,
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: ListingColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
