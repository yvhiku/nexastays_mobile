import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/colors.dart';
import '../../domain/entities/message.dart';

class TextBubble extends StatelessWidget {
  const TextBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isOwn = message.isOwn;
    final time = message.sentAt ?? message.createdAt;
    final timeLabel = DateFormat('h:mm a').format(time);

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isOwn ? 56 : 16,
        right: isOwn ? 16 : 56,
      ),
      child: Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isOwn ? DSColors.primary : DSColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isOwn ? 18 : 4),
                  bottomRight: Radius.circular(isOwn ? 4 : 18),
                ),
                border: isOwn ? null : Border.all(color: DSColors.line),
                boxShadow: isOwn
                    ? [
                        BoxShadow(
                          color: DSColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  message.body ?? '',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    height: 1.35,
                    color: isOwn ? Colors.white : DSColors.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: DSColors.ink4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
