import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../navigation/app_routes.dart';
import '../../../../services/location_service.dart';
import '../../../home/domain/entities/property.dart';
import '../../../property/presentation/widgets/stay_card.dart';

/// Last-resort center when geolocation is denied / unavailable.
const _fallback = LatLng(31.6295, -7.9811); // Marrakech

class ExploreMap extends StatefulWidget {
  const ExploreMap({
    super.key,
    required this.properties,
    this.preferListingsCenter = false,
  });

  final List<Property> properties;

  /// When true (e.g. city filter), frame the map around listing pins.
  final bool preferListingsCenter;

  @override
  State<ExploreMap> createState() => _ExploreMapState();
}

class _MapCluster {
  _MapCluster({required this.properties, required this.center});

  final List<Property> properties;
  final LatLng center;

  bool get isSingle => properties.length == 1;
}

class _ExploreMapState extends State<ExploreMap> {
  final _mapController = MapController();
  final _locationService = LocationService();

  LatLng? _userCenter;
  bool _locating = true;
  bool _didInitialFrame = false;
  double _zoom = 13;

  List<Property> get _mappable => widget.properties
      .where((property) => property.hasMapCoordinates)
      .toList();

  @override
  void initState() {
    super.initState();
    _zoom = (!widget.preferListingsCenter) ? 13 : (_mappable.length == 1 ? 12 : 7);
    _resolveUserLocation();
  }

  @override
  void didUpdateWidget(covariant ExploreMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.preferListingsCenter &&
        !oldWidget.preferListingsCenter &&
        _mappable.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _frameListings();
      });
    }
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
      if (!mounted || _didInitialFrame) return;
      _didInitialFrame = true;
      if (!widget.preferListingsCenter && _userCenter != null) {
        _mapController.move(_userCenter!, 13);
        setState(() => _zoom = 13);
      } else if (widget.preferListingsCenter && _mappable.isNotEmpty) {
        _frameListings();
      }
    });
  }

  void _frameListings() {
    final points = _mappable
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 14);
      setState(() => _zoom = 14);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  Future<void> _goToUser() async {
    var center = _userCenter;
    if (center == null) {
      final position = await _locationService.getCurrentLocation();
      if (position == null || !mounted) return;
      center = LatLng(position.latitude, position.longitude);
      setState(() => _userCenter = center);
    }
    _mapController.move(center, 13);
    setState(() => _zoom = 13);
  }

  LatLng get _initialCenter {
    if (!widget.preferListingsCenter && _userCenter != null) {
      return _userCenter!;
    }
    if (_mappable.isNotEmpty) {
      return LatLng(_mappable.first.latitude!, _mappable.first.longitude!);
    }
    return _userCenter ?? _fallback;
  }

  /// Grid clustering: zoomed out → count bubbles; zoomed in → each stay.
  List<_MapCluster> _clustersForZoom(double zoom) {
    final items = _mappable;
    if (items.isEmpty) return const [];

    // Fully expand individuals once close enough.
    if (zoom >= 15) {
      return [
        for (final p in items)
          _MapCluster(
            properties: [p],
            center: LatLng(p.latitude!, p.longitude!),
          ),
      ];
    }

    final cellDeg = zoom <= 8
        ? 1.2
        : zoom <= 10
            ? 0.45
            : zoom <= 12
                ? 0.18
                : zoom <= 14
                    ? 0.08
                    : 0.03;

    final buckets = <String, List<Property>>{};
    for (final property in items) {
      final lat = property.latitude!;
      final lng = property.longitude!;
      final key =
          '${(lat / cellDeg).floor()}_${(lng / cellDeg).floor()}';
      buckets.putIfAbsent(key, () => <Property>[]).add(property);
    }

    return [
      for (final group in buckets.values)
        _MapCluster(
          properties: group,
          center: LatLng(
            group.map((p) => p.latitude!).reduce((a, b) => a + b) /
                group.length,
            group.map((p) => p.longitude!).reduce((a, b) => a + b) /
                group.length,
          ),
        ),
    ];
  }

  void _onClusterTap(_MapCluster cluster) {
    if (cluster.isSingle) {
      _showPreview(cluster.properties.first);
      return;
    }
    final points = cluster.properties
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();
    if (points.length == 1) {
      _mapController.move(points.first, (_zoom + 2).clamp(1, 18));
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(56)),
    );
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
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_locating) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFE8507A)),
            SizedBox(height: 12),
            Text(
              'Finding your location…',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final clusters = _clustersForZoom(_zoom);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: _zoom,
            onPositionChanged: (camera, _) {
              final next = camera.zoom;
              if ((next - _zoom).abs() < 0.05) return;
              setState(() => _zoom = next);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.nexa_stays_f',
            ),
            MarkerLayer(
              markers: [
                if (_userCenter != null)
                  Marker(
                    point: _userCenter!,
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final cluster in clusters)
                  if (cluster.isSingle)
                    Marker(
                      point: cluster.center,
                      width: 96,
                      height: 40,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _onClusterTap(cluster),
                        child: _PriceBubble(
                          label:
                              '${cluster.properties.first.pricePerNight.round()} MAD',
                        ),
                      ),
                    )
                  else
                    Marker(
                      point: cluster.center,
                      width: cluster.properties.length < 10 ? 44 : 52,
                      height: cluster.properties.length < 10 ? 44 : 52,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _onClusterTap(cluster),
                        child: _ClusterBubble(count: cluster.properties.length),
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
                _mappable.isEmpty
                    ? 'Explore nearby'
                    : '${_mappable.length} of ${widget.properties.length} stays on map',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 16,
          child: Material(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              onTap: _goToUser,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location, size: 16, color: Color(0xFFE8507A)),
                    SizedBox(width: 6),
                    Text(
                      'Near me',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_mappable.isEmpty)
          Positioned(
            top: 56,
            left: 16,
            right: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No stays nearby on the map yet. Pan around or clear filters to explore other areas.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
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
        color: const Color(0xFFE8507A),
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
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClusterBubble extends StatelessWidget {
  const _ClusterBubble({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8507A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8507A).withValues(alpha: 0.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
