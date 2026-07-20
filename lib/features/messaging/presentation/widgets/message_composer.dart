import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/motion.dart';
import '../../../../design_system/tokens/colors.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.canSend,
    this.isSending = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool canSend;
  final bool isSending;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final enabled = widget.canSend &&
        !widget.isSending &&
        widget.controller.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: DSColors.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                enabled: widget.canSend && !widget.isSending,
                onChanged: widget.onChanged,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: widget.canSend
                      ? 'Write a message…'
                      : 'Messaging is read-only',
                  hintStyle: GoogleFonts.dmSans(
                    color: DSColors.ink4,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: DSColors.background2,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: enabled ? 1 : 0.9,
              duration: DSMotion.fastDuration,
              child: Material(
                color: enabled ? DSColors.primary : DSColors.line,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: enabled ? widget.onSend : null,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: widget.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
