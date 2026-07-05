import 'package:flutter/material.dart';

import '../../domain/entities/dispute.dart';

// =============================================================================
// Dispute Timeline Widget
// =============================================================================

class DisputeTimeline extends StatelessWidget {
  const DisputeTimeline({
    super.key,
    required this.events,
    required this.isPending,
  });

  final List<DisputeTimelineEvent> events;
  final bool isPending;

  // ── Dot color ────────────────────────────────────────────────────────

  Color _dotColor(DisputeTimelineEvent event) {
    if (event.isSystemEvent) return const Color(0xFF9CA3AF);
    return switch (event.actor) {
      'nexa' => const Color(0xFFE8507A),
      'guest' => const Color(0xFF3B82F6),
      'host' => const Color(0xFF16A34A),
      _ => const Color(0xFF9CA3AF),
    };
  }

  // ── Actor badge ──────────────────────────────────────────────────────

  Widget? _actorBadge(DisputeTimelineEvent event) {
    if (event.isSystemEvent) return null;

    final (label, bg, fg) = switch (event.actor) {
      'nexa' => ('⚖️ Nexa Stays', const Color(0xFFEDE9FE), const Color(0xFF7C3AED)),
      'guest' => ('👤 You', const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      'host' => ('🏠 Host', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      _ => (null, Colors.transparent, Colors.transparent),
    };

    if (label == null) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  // ── Timestamp format ─────────────────────────────────────────────────

  String _formatTimestamp(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute';
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header.
        const Text(
          'Case timeline',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),

        // Timeline events.
        ...List.generate(events.length, (index) {
          final event = events[index];
          final isLast = index == events.length - 1 && !isPending;

          return _TimelineRow(
            dotColor: _dotColor(event),
            showLine: !isLast,
            badge: _actorBadge(event),
            message: event.message,
            timestamp: _formatTimestamp(event.timestamp),
            isSystemEvent: event.isSystemEvent,
          );
        }),

        // Pending indicator.
        if (isPending) _buildPendingIndicator(),
      ],
    );
  }

  Widget _buildPendingIndicator() {
    return _PendingDot();
  }
}

// =============================================================================
// Timeline Row
// =============================================================================

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.dotColor,
    required this.showLine,
    this.badge,
    required this.message,
    required this.timestamp,
    this.isSystemEvent = false,
  });

  final Color dotColor;
  final bool showLine;
  final Widget? badge;
  final String message;
  final String timestamp;
  final bool isSystemEvent;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: dot + line ──────────────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),

          // ── Right: content ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) badge!,
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isSystemEvent
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Pending Dot (animated pulse)
// =============================================================================

class _PendingDot extends StatefulWidget {
  @override
  State<_PendingDot> createState() => _PendingDotState();
}

class _PendingDotState extends State<_PendingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: animated dot.
        SizedBox(
          width: 40,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8507A).withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Right: pending message.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Nexa is reviewing your case...',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
