import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalkthroughVideoStep extends StatefulWidget {
  const WalkthroughVideoStep({
    super.key,
    required this.videoPath,
    required this.onVideoSelected,
    required this.onSubmit,
    required this.isSubmitting,
  });

  /// Path to the selected video file
  final String? videoPath;

  /// Callback when a video is selected or removed
  final ValueChanged<String> onVideoSelected;

  /// Callback when the "Submit for Approval →" button is pressed
  final VoidCallback onSubmit;

  /// Loading state indicator for submission
  final bool isSubmitting;

  @override
  State<WalkthroughVideoStep> createState() => _WalkthroughVideoStepState();
}

class _WalkthroughVideoStepState extends State<WalkthroughVideoStep> {
  String? _fileName;
  String? _fileSize;

  @override
  void initState() {
    super.initState();
    _loadFileInfo();
  }

  @override
  void didUpdateWidget(WalkthroughVideoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPath != oldWidget.videoPath) {
      _loadFileInfo();
    }
  }

  Future<void> _loadFileInfo() async {
    if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
      final file = File(widget.videoPath!);
      if (await file.exists()) {
        final bytes = await file.length();
        setState(() {
          _fileName = widget.videoPath!.split('/').last;
          _fileSize = _formatBytes(bytes);
        });
        return;
      }
    }
    setState(() {
      _fileName = null;
      _fileSize = null;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        widget.onVideoSelected(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVideo =
        widget.videoPath != null && widget.videoPath!.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verified walkthrough video',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Required for guest comfort and security.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // ── IF VIDEO IS SELECTED ──
          if (hasVideo) ...[
            // Static video preview card (avoids Impeller/Vulkan crash on emulators)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_fileName != null)
                    Text(
                      _fileName!,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  if (_fileSize != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _fileSize!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        'Video ready',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickVideo,
                  child: Text(
                    'Re-record',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // ── VIDEO SEQUENCE INSTRUCTIONS ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE8507A).withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Text('🎥', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    'Required video sequence:',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSequenceRow(1, 'Show your face (3–5 sec)'),
                  const SizedBox(height: 10),
                  _buildSequenceRow(2, 'Walk to the door'),
                  const SizedBox(height: 10),
                  _buildSequenceRow(3, 'Walk through'),
                  const SizedBox(height: 10),
                  _buildSequenceRow(4, 'Full walkthrough'),
                  const SizedBox(height: 20),
                  Text(
                    '45 sec – 2 min • Continuous • Must match listing',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF9CA3AF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── ACTION BUTTONS ──
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickVideo,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F5),
                        border: Border.all(color: const Color(0xFFE8507A)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '📤 Upload Video',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE8507A),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickVideo,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8507A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '🔴 Record Now',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 40),

          // ── SUBMIT BUTTON ──
          GestureDetector(
            onTap: hasVideo && !widget.isSubmitting ? widget.onSubmit : null,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: hasVideo
                    ? const LinearGradient(
                        colors: [Color(0xFFE8507A), Color(0xFFED4B82)],
                      )
                    : null,
                color: hasVideo ? null : const Color(0xFFF3F4F6),
              ),
              alignment: Alignment.center,
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit for Approval →',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color:
                            hasVideo ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSequenceRow(int number, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFE8507A),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
