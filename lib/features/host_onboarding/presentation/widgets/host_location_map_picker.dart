import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../services/location_service.dart';

/// Lets hosts pin their listing on the OSM map so guests can find it in Explore.
class HostLocationMapPicker extends StatefulWidget {
  const HostLocationMapPicker({
    super.key,
    required this.city,
    required this.neighborhood,
    required this.address,
    this.latitude,
    this.longitude,
    required this.onCoordinatesChanged,
  });

  final String city;
  final String neighborhood;
  final String address;
  final double? latitude;
  final double? longitude;
  final ValueChanged<LatLng> onCoordinatesChanged;

  @override
  State<HostLocationMapPicker> createState() => _HostLocationMapPickerState();
}

class _HostLocationMapPickerState extends State<HostLocationMapPicker> {
  static const _fallback = LatLng(31.6295, -7.9811); // last resort only

  final _mapController = MapController();
  final _locationService = LocationService();

  LatLng? _pin;
  LatLng? _userCenter;
  bool _locating = true;
  bool _geocoding = false;
  String? _error;
  bool _didInitialMove = false;

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      _pin = LatLng(widget.latitude!, widget.longitude!);
    }
    _resolveUserLocation();
  }

  @override
  void didUpdateWidget(covariant HostLocationMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      if (widget.latitude != null && widget.longitude != null) {
        _pin = LatLng(widget.latitude!, widget.longitude!);
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _resolveUserLocation() async {
    setState(() => _locating = true);
    final position = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      if (position != null) {
        _userCenter = LatLng(position.latitude, position.longitude);
      }
      _locating = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInitialMove) return;
      _didInitialMove = true;
      if (_pin != null) {
        _mapController.move(_pin!, 15);
      } else if (_userCenter != null) {
        _mapController.move(_userCenter!, 14);
      }
    });
  }

  String get _query {
    final parts = [
      widget.address.trim(),
      widget.neighborhood.trim(),
      widget.city.trim(),
      'Morocco',
    ].where((p) => p.isNotEmpty);
    return parts.join(', ');
  }

  Future<void> _placeOnMap() async {
    final query = _query;
    if (query.replaceAll(RegExp(r'[,\s]'), '').isEmpty) {
      setState(() => _error = 'Enter city and address first.');
      return;
    }

    setState(() {
      _geocoding = true;
      _error = null;
    });

    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'NexaStays/1.0 (host-listing-map)',
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
          _geocoding = false;
          _error = 'Could not find that address. Try a clearer street or city.';
        });
        return;
      }

      final first = results.first as Map<String, dynamic>;
      final pin = LatLng(
        double.parse(first['lat'] as String),
        double.parse(first['lon'] as String),
      );
      setState(() {
        _pin = pin;
        _geocoding = false;
      });
      widget.onCoordinatesChanged(pin);
      _mapController.move(pin, 15);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _geocoding = false;
        _error =
            'Could not place address on map. Check the address and try again.';
      });
    }
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _geocoding = true;
      _error = null;
    });
    try {
      var center = _userCenter;
      if (center == null) {
        final position = await _locationService.getCurrentLocation();
        if (position == null) {
          if (!mounted) return;
          setState(() {
            _geocoding = false;
            _error =
                'Could not get your location. Allow location access and try again.';
          });
          return;
        }
        center = LatLng(position.latitude, position.longitude);
      }
      if (!mounted) return;
      setState(() {
        _userCenter = center;
        _pin = center;
        _geocoding = false;
      });
      widget.onCoordinatesChanged(center!);
      _mapController.move(center, 15);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _geocoding = false;
        _error =
            'Could not get your location. Allow location access and try again.';
      });
    }
  }

  void _setPin(LatLng position) {
    setState(() {
      _pin = position;
      _error = null;
    });
    widget.onCoordinatesChanged(position);
  }

  LatLng get _initialCenter => _pin ?? _userCenter ?? _fallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Map location *',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Guests see this pin on Explore map. Tap the map to fine-tune after placing.',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _geocoding || _locating ? null : _placeOnMap,
                icon: _geocoding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.place_outlined, size: 18),
                label: Text(
                  _pin == null
                      ? 'Find address on map'
                      : 'Update pin from address',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8507A),
                  side: const BorderSide(color: Color(0xFFE8507A)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _geocoding || _locating ? null : _useMyLocation,
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(
                'Near me',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A2E),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 220,
            child: _locating
                ? const ColoredBox(
                    color: Color(0xFFF3F4F6),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFE8507A)),
                          SizedBox(height: 10),
                          Text(
                            'Finding your location…',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialCenter,
                      initialZoom: _pin != null
                          ? 15
                          : (_userCenter != null ? 14 : 11),
                      onTap: (_, point) => _setPin(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.nexa_stays_f',
                      ),
                      MarkerLayer(
                        markers: [
                          if (_userCenter != null)
                            Marker(
                              point: _userCenter!,
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          if (_pin != null)
                            Marker(
                              point: _pin!,
                              width: 40,
                              height: 40,
                              alignment: Alignment.bottomCenter,
                              child: const Icon(
                                Icons.location_on,
                                size: 40,
                                color: Color(0xFFE8507A),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _pin == null
              ? 'No pin yet — find the address, use your location, or tap the map.'
              : 'Pinned · ${_pin!.latitude.toStringAsFixed(5)}, ${_pin!.longitude.toStringAsFixed(5)}',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: _pin == null
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF059669),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFFB91C1C),
            ),
          ),
        ],
      ],
    );
  }
}
