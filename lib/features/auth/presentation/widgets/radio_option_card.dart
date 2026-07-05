import 'package:flutter/material.dart';

class RadioOptionCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsets margin;
  final bool hasIcon;

  const RadioOptionCard({
    super.key,
    required this.label,
    this.subtitle,
    this.emoji,
    required this.isSelected,
    required this.onTap,
    this.margin = const EdgeInsets.only(bottom: 8),
    this.hasIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF0F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8507A) : const Color(0xFFEDE0E5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasIcon && emoji != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8507A).withOpacity(0.12)
                      : const Color(0xFFF8F2F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(emoji!, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasIcon ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFFC93A62)
                          : const Color(0xFF1A1118),
                    ),
                  ),
                  if (subtitle != null && hasIcon) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFFF4809A)
                            : const Color(0xFF9E8A93),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFE8507A) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE8507A)
                      : const Color(0xFFEDE0E5),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
