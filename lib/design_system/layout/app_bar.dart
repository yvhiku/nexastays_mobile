// =============================================================================
// NexaStays Design System — App Bar
// =============================================================================
// Custom translucent app bar supporting nested titles, the NexaStays logo
// for root pages, and standard action areas.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// The standard top navigation bar for NexaStays screens.
///
/// If [showBackButton] is `false`, it assumes it's on a root page and
/// displays the NexaStays leaf logo in the leading position.
///
/// Features a slight blur effect natively supported by Material when
/// `surfaceTintColor` and `backgroundColor` are configured with alpha.
///
/// ```dart
/// // Example usage in HomePage:
/// AppScaffold(
///   appBar: DSAppBar(
///     title: 'Discover Stays',
///     showBackButton: false,
///     actions: [
///       IconButton(
///         icon: const Icon(Icons.search),
///         onPressed: () => context.pushNamed('search'),
///       ),
///     ],
///   ),
///   body: Container(),
/// )
/// ```
class DSAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DSAppBar({
    this.title,
    this.actions,
    this.showBackButton = false,
    super.key,
  });

  /// Optional string title displayed in the center. Uses [DSTypography.heading3].
  final String? title;

  /// Optional list of icon buttons displayed on the trailing (right) edge.
  final List<Widget>? actions;

  /// If `true`, shows a standard back-arrow. If `false`, shows the NexaStays logo.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    // 💡 SCROLL LISTENER NOTE:
    // To implement dynamic background opacity when the user scrolls down
    // (making the AppBar turn solid white with a shadow), the parent screen
    // should use a `SliverAppBar` inside a `CustomScrollView` or wire a
    // `ScrollController` listener to statefully update a `scrolled` boolean
    // passed into this widget.
    //
    // For now, it relies on Flutter's Material 3 defaults (`scrolledUnderElevation`)
    // which automatically tints and elevates when content scrolls underneath.

    return AppBar(
      // Ensure the background is semi-transparent so the Material 3 blur shows through
      backgroundColor: DSColors.surface.withValues(alpha: 0.95),
      scrolledUnderElevation: 1.0,
      elevation: 0,
      centerTitle: true,

      // ── Leading Area ──────────────────────────────────────────────────
      automaticallyImplyLeading: false, // We control this manually
      leading: showBackButton
          ? Semantics(
              label: 'Go back',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: DSColors.neutral,
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            )
          : Semantics(
              label: 'NexaStays Logo',
              image: true,
              child: Padding(
                padding: const EdgeInsets.only(left: DSSpacing.m),
                child: Center(
                  child: Image.asset(
                    AppAssets.logo,
                    height: 28, // Small logo sizing
                    width: 28,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
      leadingWidth: showBackButton ? 56.0 : 64.0,

      // ── Title Area ────────────────────────────────────────────────────
      title: title != null
          ? Text(
              title!,
              style: DSTypography.heading3.copyWith(
                // Tighten tracking slightly for top navigation
                letterSpacing: -0.2,
              ),
            )
          : null,

      // ── Actions Area ──────────────────────────────────────────────────
      actions: actions != null
          ? [
              ...actions!,
              // Inject a tiny bit of trailing padding so icons don't hit the bezel
              const SizedBox(width: DSSpacing.s),
            ]
          : null,

      // ── Bottom Border ─────────────────────────────────────────────────
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: DSColors.muted.withValues(alpha: 0.5),
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
