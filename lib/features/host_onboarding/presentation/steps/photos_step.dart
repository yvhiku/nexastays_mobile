import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PhotosStep extends StatefulWidget {
  const PhotosStep({
    super.key,
    required this.photoPaths,
    required this.onPhotosChanged,
  });

  /// The current list of local photo file paths.
  final List<String> photoPaths;

  /// Callback to emit the updated paths list when photos are added/removed.
  final ValueChanged<List<String>> onPhotosChanged;

  @override
  State<PhotosStep> createState() => _PhotosStepState();
}

class _PhotosStepState extends State<PhotosStep> {
  final ImagePicker _picker = ImagePicker();

  // Track which room category chip is currently selected
  String _selectedCategory = 'Entrance';

  final List<Map<String, String>> _categories = const [
    {'emoji': '🚪', 'label': 'Entrance'},
    {'emoji': '🛋', 'label': 'Living'},
    {'emoji': '🛏', 'label': 'Bedroom'},
    {'emoji': '🚿', 'label': 'Bathroom'},
    {'emoji': '🍳', 'label': 'Kitchen'},
    {'emoji': '🪟', 'label': 'Terrace'},
    {'emoji': '📍', 'label': 'Area feel'},
    {'emoji': '➕', 'label': 'Add more'},
  ];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      final newPaths = List<String>.from(widget.photoPaths)
        ..addAll(images.map((e) => e.path));
      widget.onPhotosChanged(newPaths);
    }
  }

  void _removeImage(int index) {
    final newPaths = List<String>.from(widget.photoPaths)..removeAt(index);
    widget.onPhotosChanged(newPaths);
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.photoPaths.length;
    final bool hasReachedMin = count >= 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property photos',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Minimum 12 photos required.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),

        // ── TIP Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'High-quality, well-lit photos get 3× more bookings.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── ROOM CATEGORY CHIPS
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category['label'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['label']!;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFFFF0F5) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE8507A)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category['emoji']!),
                        const SizedBox(width: 4),
                        Text(
                          category['label']!,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFFE8507A)
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // ── PHOTO GRID
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            // +1 for the "Add More" trailing button
            itemCount: count + 1,
            itemBuilder: (context, index) {
              if (index == count) {
                // "Add More" Button
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(10),
                      // Dashed border effect imitation (Flutter doesn't have native dashed borders)
                      // A custom painter could be used, but solid/light border suffices for basic layout
                      border: Border.all(
                        color: const Color(0xFFE8507A).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Color(0xFFE8507A),
                        size: 32,
                      ),
                    ),
                  ),
                );
              }

              // Uploaded Photo Thumbnail
              final photoPath = widget.photoPaths[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(
                            photoPath,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(photoPath),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8507A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // ── PHOTO COUNT BADGE
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count / 12',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                hasReachedMin
                    ? '✓ Minimum reached'
                    : '${12 - count} more needed',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasReachedMin
                      ? const Color(0xFF10B981) // Green
                      : const Color(0xFFF59E0B), // Orange
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
