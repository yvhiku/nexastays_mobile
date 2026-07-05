import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'filter_chip.dart';

class VibeChip extends StatefulWidget {
  const VibeChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<VibeChip> createState() => _VibeChipState();
}

class _VibeChipState extends State<VibeChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: NexaFilterChip.chipHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFFFFF0F5) : Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFE8507A)
                  : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.emoji,
                textHeightBehavior: NexaFilterChip.chipTextHeight,
                style: const TextStyle(fontSize: 14, height: 1),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                textHeightBehavior: NexaFilterChip.chipTextHeight,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  height: 1,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? const Color(0xFFE8507A)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VibeChipRow extends StatelessWidget {
  const VibeChipRow({
    super.key,
    required this.selectedTags,
    required this.onToggle,
  });

  final List<String> selectedTags;
  final ValueChanged<String> onToggle;

  static const List<Map<String, String>> _defaultVibes = [
    {'emoji': '🌅', 'label': 'Rooftop sunsets', 'tag': 'rooftop'},
    {'emoji': '🕌', 'label': 'Riad magic', 'tag': 'riad'},
    {'emoji': '🌊', 'label': 'Ocean view', 'tag': 'ocean'},
    {'emoji': '🏜', 'label': 'Desert escape', 'tag': 'desert'},
    {'emoji': '🏙', 'label': 'City center', 'tag': 'city'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _defaultVibes.map((vibe) {
          final tag = vibe['tag']!;
          final isSelected = selectedTags.contains(tag);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: VibeChip(
              emoji: vibe['emoji']!,
              label: vibe['label']!,
              tag: tag,
              isSelected: isSelected,
              onTap: () => onToggle(tag),
            ),
          );
        }).toList(),
      ),
    );
  }
}
