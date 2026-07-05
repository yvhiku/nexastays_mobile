import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/entities/dispute.dart';
import 'bloc/dispute_cubit.dart';
import 'bloc/dispute_state.dart';
import 'widgets/dispute_timeline.dart';

// =============================================================================
// Dispute Status Page
// =============================================================================

class DisputeStatusPage extends StatefulWidget {
  const DisputeStatusPage({
    super.key,
    this.disputeId,
    this.bookingId,
  });

  final String? disputeId;
  final String? bookingId;

  @override
  State<DisputeStatusPage> createState() => _DisputeStatusPageState();
}

class _DisputeStatusPageState extends State<DisputeStatusPage> {
  @override
  void initState() {
    super.initState();
    context.read<DisputeCubit>().loadDisputeStatus(
          disputeId: widget.disputeId,
          bookingId: widget.bookingId,
        );
  }

  String _shortId(String id) =>
      id.length > 4 ? id.substring(id.length - 4).toUpperCase() : id.toUpperCase();

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m';
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<DisputeCubit, DisputeState>(
        listener: (context, state) {
          if (state is DisputeClosed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Case closed',
                  style: TextStyle(fontSize: 13),
                ),
                backgroundColor: const Color(0xFF1A1A2E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is DisputeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontSize: 13),
                ),
                backgroundColor: const Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DisputeLoaded) {
            return _buildLoaded(context, state.dispute);
          }
          if (state is DisputeClosing || state is DisputeAddingEvidence) {
            return _buildLoading();
          }
          if (state is DisputeError) {
            return _buildError(context, state);
          }
          // Initial / loading.
          return _buildShimmer();
        },
      ),
    );
  }

  // ── Loaded ────────────────────────────────────────────────────────────

  Widget _buildLoaded(BuildContext context, Dispute dispute) {
    final cubit = context.read<DisputeCubit>();

    return CustomScrollView(
      slivers: [
        // App bar.
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: const Color(0xFF1A1A2E),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Dispute #${_shortId(dispute.id)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              color: const Color(0xFF374151),
              onPressed: () => cubit.loadDisputeStatus(
                disputeId: dispute.id,
              ),
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Status banner ──────────────────────────────────
              _buildStatusBanner(dispute),
              const SizedBox(height: 20),

              // ── Summary card ───────────────────────────────────
              _buildSummaryCard(dispute),
              const SizedBox(height: 16),

              // ── Description card ───────────────────────────────
              _buildDescriptionCard(dispute),
              const SizedBox(height: 16),

              // ── Evidence section ───────────────────────────────
              if (dispute.evidenceUrls.isNotEmpty) ...[
                _buildEvidenceSection(dispute),
                const SizedBox(height: 16),
              ],

              // ── Add evidence button ────────────────────────────
              if (dispute.canAddEvidence) ...[
                _buildAddEvidenceButton(cubit, dispute),
                const SizedBox(height: 16),
              ],

              // ── Timeline ───────────────────────────────────────
              DisputeTimeline(
                events: dispute.timeline,
                isPending: dispute.isPending,
              ),
              const SizedBox(height: 20),

              // ── Refund card ────────────────────────────────────
              if (dispute.isResolved &&
                  dispute.refundAmount != null &&
                  dispute.refundAmount! > 0) ...[
                _buildRefundCard(dispute),
                const SizedBox(height: 20),
              ],

              // ── Action buttons ─────────────────────────────────
              if (dispute.status == DisputeStatus.resolved ||
                  dispute.status == DisputeStatus.rejected) ...[
                _buildCloseButton(cubit, dispute.id),
                const SizedBox(height: 12),
              ],

              // ── Contact support ────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('mailto:support@nexastays.ma'),
                  ),
                  child: const Text(
                    'Contact Nexa support',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Status banner ────────────────────────────────────────────────────

  Widget _buildStatusBanner(Dispute dispute) {
    final (bg, border, emoji, title, titleColor, subtitle) =
        switch (dispute.status) {
      DisputeStatus.open => (
          const Color(0xFFEDE9FE),
          const Color(0xFFDDD6FE),
          '⚖️',
          'Dispute submitted',
          const Color(0xFF7C3AED),
          "We'll review your case within 24–48 hours.",
        ),
      DisputeStatus.underReview => (
          const Color(0xFFFFFBEB),
          const Color(0xFFFDE68A),
          '⏳',
          'Under review',
          const Color(0xFFD97706),
          'Nexa team is investigating...',
        ),
      DisputeStatus.awaitingHost => (
          const Color(0xFFDBEAFE),
          const Color(0xFFBAE6FD),
          '📬',
          'Awaiting host response',
          const Color(0xFF1D4ED8),
          "We've contacted the host and are waiting for their response.",
        ),
      DisputeStatus.resolved => _resolvedBannerData(dispute),
      DisputeStatus.rejected => (
          const Color(0xFFFEF2F2),
          const Color(0xFFFECACA),
          '✗',
          'Dispute rejected',
          const Color(0xFFDC2626),
          dispute.resolutionNote ?? 'Your dispute was not upheld.',
        ),
      DisputeStatus.closed => (
          const Color(0xFFF3F4F6),
          const Color(0xFFE5E7EB),
          '✓',
          'Case closed',
          const Color(0xFF6B7280),
          'This dispute has been closed.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String, String, Color, String) _resolvedBannerData(
    Dispute dispute,
  ) {
    final hasRefund = dispute.resolution == DisputeResolution.fullRefund ||
        dispute.resolution == DisputeResolution.partialRefund;

    if (hasRefund) {
      final refundText = dispute.refundAmount != null
          ? 'A refund of ${dispute.refundAmount!.toStringAsFixed(0)} MAD will be processed within 3–5 business days.'
          : 'Your refund will be processed shortly.';
      return (
        const Color(0xFFF0FDF4),
        const Color(0xFFBBF7D0),
        '✓',
        'Resolved in your favour',
        const Color(0xFF16A34A),
        refundText,
      );
    }

    return (
      const Color(0xFFFFFBEB),
      const Color(0xFFFDE68A),
      'ℹ️',
      'Case resolved',
      const Color(0xFFD97706),
      dispute.resolutionNote ?? 'The case has been resolved.',
    );
  }

  // ── Summary card ─────────────────────────────────────────────────────

  Widget _buildSummaryCard(Dispute dispute) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property: ${dispute.propertyName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Booking ID: #${_shortId(dispute.bookingId)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF3F4F6), height: 1),
          ),
          Row(
            children: [
              const Text(
                'Issue type',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  dispute.typeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Opened: ${_formatDate(dispute.openedAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ── Description card ─────────────────────────────────────────────────

  Widget _buildDescriptionCard(Dispute dispute) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dispute.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Evidence section ─────────────────────────────────────────────────

  Widget _buildEvidenceSection(Dispute dispute) {
    const videoExts = ['.mp4', '.mov', '.avi', '.mkv'];
    bool isVideo(String url) {
      final lower = url.toLowerCase();
      return videoExts.any((ext) => lower.contains(ext));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence submitted (${dispute.evidenceUrls.length} files)',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dispute.evidenceUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = dispute.evidenceUrls[index];
              final video = isVideo(url);

              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: video
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
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: const Color(0xFFF3F4F6),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 24,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Add evidence button ──────────────────────────────────────────────

  Widget _buildAddEvidenceButton(DisputeCubit cubit, Dispute dispute) {
    return OutlinedButton.icon(
      onPressed: () {
        // For simplicity, trigger a file pick and add.
        // In production this would open the EvidenceUploader in a sheet.
      },
      icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
      label: const Text('Add more evidence'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF7C3AED),
        side: const BorderSide(color: Color(0xFF7C3AED)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  // ── Refund card ──────────────────────────────────────────────────────

  Widget _buildRefundCard(Dispute dispute) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💰', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refund: ${dispute.refundAmount!.toStringAsFixed(0)} MAD',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Processing: 3–5 business days to your original payment method.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Close button ─────────────────────────────────────────────────────

  Widget _buildCloseButton(DisputeCubit cubit, String disputeId) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => cubit.closeDispute(disputeId),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6B7280),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Close case',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
      ),
    );
  }

  // ── Shimmer ──────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1A1A2E),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 16,
          width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner skeleton.
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 20),
            // Summary skeleton.
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // Description skeleton.
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 16),
            // Timeline skeleton.
            ...List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, DisputeError state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1A1A2E),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Could not load dispute',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    this.context.read<DisputeCubit>().loadDisputeStatus(
                          disputeId: widget.disputeId,
                          bookingId: widget.bookingId,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
