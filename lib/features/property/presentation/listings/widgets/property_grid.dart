import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../home/domain/entities/property.dart';
import 'property_list_card.dart';

// ─── Layout Enum ─────────────────────────────────────────────────────────────

enum PropertyGridLayout { list, grid }

// ─── PropertyGrid ────────────────────────────────────────────────────────────

/// Displays a collection of [Property] items in either a vertical list
/// (default) or a two-column grid.
///
/// An optional layout toggle row can be shown above the items via
/// [showLayoutToggle].
class PropertyGrid extends StatelessWidget {
  const PropertyGrid({
    super.key,
    required this.properties,
    required this.savedPropertyIds,
    required this.onPropertyTap,
    required this.onSaveToggle,
    this.layout = PropertyGridLayout.list,
    this.showLayoutToggle = false,
    this.onLayoutChanged,
    this.onLoadMore,
  });

  final List<Property> properties;
  final Set<String> savedPropertyIds;
  final ValueChanged<Property> onPropertyTap;
  final ValueChanged<String> onSaveToggle;
  final PropertyGridLayout layout;
  final bool showLayoutToggle;
  final ValueChanged<PropertyGridLayout>? onLayoutChanged;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Toggle bar ─────────────────────────────────────────────────
        if (showLayoutToggle) _LayoutToggle(active: layout, onChanged: onLayoutChanged),

        // ── Content ────────────────────────────────────────────────────
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (onLoadMore != null &&
                  notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 200) {
                onLoadMore!();
              }
              return false;
            },
            child: layout == PropertyGridLayout.list
                ? _buildListView()
                : _buildGridView(),
          ),
        ),
      ],
    );
  }

  // ── List view ──────────────────────────────────────────────────────────────

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PropertyListCard(
            property: property,
            onTap: () => onPropertyTap(property),
          ),
        );
      },
    );
  }

  // ── Grid view ──────────────────────────────────────────────────────────────

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final isSaved = savedPropertyIds.contains(property.id);
        return PropertyGridCard(
          property: property,
          isSaved: isSaved,
          onTap: () => onPropertyTap(property),
          onSaveToggle: () => onSaveToggle(property.id),
        );
      },
    );
  }
}

// ─── Layout Toggle ──────────────────────────────────────────────────────────

class _LayoutToggle extends StatelessWidget {
  const _LayoutToggle({required this.active, this.onChanged});

  final PropertyGridLayout active;
  final ValueChanged<PropertyGridLayout>? onChanged;

  static const _accent = Color(0xFFE8507A);
  static const _inactive = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _toggleIcon(
            icon: Icons.view_list_rounded,
            isActive: active == PropertyGridLayout.list,
            onTap: () => onChanged?.call(PropertyGridLayout.list),
          ),
          const SizedBox(width: 8),
          _toggleIcon(
            icon: Icons.grid_view_rounded,
            isActive: active == PropertyGridLayout.grid,
            onTap: () => onChanged?.call(PropertyGridLayout.grid),
          ),
        ],
      ),
    );
  }

  Widget _toggleIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? _accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 22, color: isActive ? _accent : _inactive),
      ),
    );
  }
}

// ─── PropertyGridCard (vertical card for grid mode) ─────────────────────────

/// A compact vertical card used inside the two-column grid layout.
class PropertyGridCard extends StatelessWidget {
  const PropertyGridCard({
    super.key,
    required this.property,
    this.isSaved = false,
    this.onTap,
    this.onSaveToggle,
  });

  final Property property;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSaveToggle;

  static const _accent = Color(0xFFE8507A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: property.images.isNotEmpty
                        ? property.images.first
                        : 'https://via.placeholder.com/400',
                    fit: BoxFit.cover,
                  ),
                  // Save button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onSaveToggle,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isSaved ? _accent : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Neighborhood label
                    Text(
                      property.city.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: const Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Name
                    Text(
                      property.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Price + Verified badge row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${property.pricePerNight.toInt()} MAD',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (property.isTrending)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Verified',
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: _accent,
                              ),
                            ),
                          ),
                      ],
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
