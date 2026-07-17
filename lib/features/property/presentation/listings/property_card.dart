import 'package:flutter/material.dart';
import '../../domain/entities/property.dart';
import '../widgets/stay_card.dart';

/// Backwards-compatible Explore wrapper around the canonical [StayCard].
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
    return StayCard(
      stay: StayCardData.fromProperty(property),
      onTap: onTap,
      onFavoriteTap: onSaveToggle,
      isFavorite: isSaved,
    );
  }
}
