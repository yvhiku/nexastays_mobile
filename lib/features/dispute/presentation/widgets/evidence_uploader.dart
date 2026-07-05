import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// =============================================================================
// Evidence Uploader Widget
// =============================================================================

class EvidenceUploader extends StatelessWidget {
  const EvidenceUploader({
    super.key,
    required this.evidencePaths,
    required this.onAdd,
    required this.onRemove,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  final List<String> evidencePaths;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final bool isUploading;
  final double uploadProgress;

  static const _maxFiles = 5;
  static const _videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return _videoExtensions.any((ext) => lower.endsWith(ext));
  }

  // ── Picker sheet ─────────────────────────────────────────────────────

  void _showPickerSheet(BuildContext context) {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pickerOption(
                ctx,
                icon: '📸',
                label: 'Take photo',
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (file != null) onAdd(file.path);
                },
              ),
              _pickerOption(
                ctx,
                icon: '🖼️',
                label: 'Choose from gallery',
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (file != null) onAdd(file.path);
                },
              ),
              _pickerOption(
                ctx,
                icon: '🎥',
                label: 'Record video',
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await picker.pickVideo(
                    source: ImageSource.camera,
                    maxDuration: const Duration(minutes: 2),
                  );
                  if (file != null) onAdd(file.path);
                },
              ),
              _pickerOption(
                ctx,
                icon: '📁',
                label: 'Choose video from library',
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                  );
                  if (result != null && result.files.single.path != null) {
                    onAdd(result.files.single.path!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerOption(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────
        Row(
          children: [
            const Text(
              'Evidence (optional)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '${evidencePaths.length}/$_maxFiles',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload up to 5 photos or videos',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),

        const SizedBox(height: 12),

        // ── Grid (horizontal scroll) ────────────────────────────
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button.
              if (evidencePaths.length < _maxFiles)
                _AddButton(onTap: () => _showPickerSheet(context)),

              // Uploaded / uploading items.
              ...evidencePaths.map((path) {
                if (isUploading) {
                  return _UploadingItem(progress: uploadProgress);
                }
                return _UploadedItem(
                  path: path,
                  isVideo: _isVideo(path),
                  onRemove: () => onRemove(path),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Tips card ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            border: const Border(
              left: BorderSide(color: Color(0xFF0EA5E9), width: 3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡 Tips for strong evidence:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0369A1),
                ),
              ),
              const SizedBox(height: 8),
              ...[
                '• Clear photos of the issue',
                '• Video walkthrough if possible',
                '• Screenshots of any messages',
                '• Photos of check-in time/date visible',
              ].map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Add Button
// =============================================================================

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE8507A),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFFE8507A), size: 24),
            SizedBox(height: 2),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE8507A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Uploaded Item
// =============================================================================

class _UploadedItem extends StatelessWidget {
  const _UploadedItem({
    required this.path,
    required this.isVideo,
    required this.onRemove,
  });

  final String path;
  final bool isVideo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Thumbnail.
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isVideo
                ? Container(
                    color: const Color(0xFF1A1A2E),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                : kIsWeb
                    ? Image.network(
                        path,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 24,
                          ),
                        ),
                      )
                    : Image.file(
                        File(path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 24,
                          ),
                        ),
                      ),
          ),

          // Remove button.
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Color(0x99000000),
                child: Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Uploading Item (shimmer + progress)
// =============================================================================

class _UploadingItem extends StatefulWidget {
  const _UploadingItem({required this.progress});

  final double progress;

  @override
  State<_UploadingItem> createState() => _UploadingItemState();
}

class _UploadingItemState extends State<_UploadingItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<Color?> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shimmerAnimation = ColorTween(
      begin: const Color(0xFFE5E7EB),
      end: const Color(0xFFF3F4F6),
    ).animate(_shimmerController);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _shimmerAnimation.value,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFE8507A),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
