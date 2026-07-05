// =============================================================================
// Stays marketing imagery — synced from nexastays_web/images/assets
// =============================================================================

import 'package:flutter/material.dart';

/// Listing page “vibe” chips (matches [VIBE_CARDS] in nexastays_web/lib/vibe-assets.ts).
class VibeCardAsset {
  const VibeCardAsset({
    required this.id,
    required this.label,
    required this.tag,
    required this.assetPath,
    this.alignment = Alignment.center,
  });

  final String id;
  final String label;
  final String tag;
  final String assetPath;
  final Alignment alignment;
}

/// Destination city imagery (matches DESTINATION_IMAGES in nexastays_web).
class DestinationCityAsset {
  const DestinationCityAsset({
    required this.name,
    required this.assetPath,
  });

  final String name;
  final String assetPath;
}

class StaysImageAssets {
  StaysImageAssets._();

  static const String _base = 'assets/images/stays';

  static const String rooftopRiad = '$_base/rooftop-riad.jpg';
  static const String riadMagic = '$_base/riad-magic.jpg';
  static const String oceanView = '$_base/ocean-view.jpg';
  static const String cozy = '$_base/cozy.jpg';
  static const String luxury = '$_base/luxury.jpg';
  static const String familyReady = '$_base/family-ready.jpg';
  static const String howItWorks = '$_base/how-it-works.png';

  static const String marrakech = '$_base/marrakesh.jpg';
  static const String agadir = '$_base/agadir.jpg';
  static const String tangier = '$_base/tangier.jpg';
  static const String casablanca = '$_base/Casablanca-Finance-City-CFC.jpg';
  static const String fes = '$_base/fes.jpg';

  static const List<VibeCardAsset> vibeCards = [
    VibeCardAsset(
      id: 'rooftop-sunsets',
      label: 'Rooftop sunsets',
      tag: 'rooftop',
      assetPath: rooftopRiad,
      alignment: Alignment(0, 0.1),
    ),
    VibeCardAsset(
      id: 'riad-magic',
      label: 'Riad magic',
      tag: 'riad',
      assetPath: riadMagic,
      alignment: Alignment(0, -0.1),
    ),
    VibeCardAsset(
      id: 'ocean-view',
      label: 'Ocean view',
      tag: 'ocean',
      assetPath: oceanView,
    ),
    VibeCardAsset(
      id: 'cozy-quiet',
      label: 'Cozy & quiet',
      tag: 'cozy',
      assetPath: cozy,
      alignment: Alignment(0, 0.2),
    ),
    VibeCardAsset(
      id: 'luxury-minimal',
      label: 'Luxury minimal',
      tag: 'luxury',
      assetPath: luxury,
      alignment: Alignment(0, 0.3),
    ),
    VibeCardAsset(
      id: 'family-ready',
      label: 'Family ready',
      tag: 'family',
      assetPath: familyReady,
      alignment: Alignment(-1, 0),
    ),
  ];

  static const List<DestinationCityAsset> destinationCities = [
    DestinationCityAsset(name: 'Marrakech', assetPath: marrakech),
    DestinationCityAsset(name: 'Casablanca', assetPath: casablanca),
    DestinationCityAsset(name: 'Tangier', assetPath: tangier),
    DestinationCityAsset(name: 'Agadir', assetPath: agadir),
    DestinationCityAsset(name: 'Fez', assetPath: fes),
  ];

  static String? cityAssetPath(String cityName) {
    final normalized = cityName.trim().toLowerCase();
    for (final city in destinationCities) {
      if (city.name.toLowerCase() == normalized) return city.assetPath;
    }
    if (normalized == 'fès' || normalized == 'fez') return fes;
    return null;
  }
}
