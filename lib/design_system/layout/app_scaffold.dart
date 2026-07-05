// =============================================================================
// NexaStays Design System — App Scaffold
// =============================================================================
// Centralised layout container wrapping the native Material [Scaffold].
// Features automatic keyboard unfocus, max-width constraints for larger screens,
// and consistent edge padding across the application.
// =============================================================================

import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// A standard page layout wrapper for NexaStays screens.
///
/// Wraps [Scaffold] to provide:
/// - Consistent [DSColors.background].
/// - Max-width constraints (1000px) on tablet/web to prevent content stretching.
/// - Automatic keyboard dismissal when tapping outside inputs.
/// - Standardized padding via [showPadding].
///
/// ```dart
/// return AppScaffold(
///   appBar: AppBar(title: const Text('Home')),
///   showPadding: false, // For lists/scrollviews that handle their own padding
///   body: CustomScrollView(...),
/// );
/// ```
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showPadding = true,
    super.key,
  });

  /// The primary content of the screen.
  final Widget body;

  /// Optional app bar to display at the top.
  final PreferredSizeWidget? appBar;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// If `true`, applies [DSSpacing.paddingAllM] around the [body] inside the
  /// safe area. Disable this if your body uses a raw scroll view that needs
  /// to touch the screen edges. Defaults to `true`.
  final bool showPadding;

  @override
  Widget build(BuildContext context) {
    // Top-level GestureDetector catches unhandled taps and dismisses the keyboard,
    // which is standard quality-of-life on mobile.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: DSColors.background,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,

        // Let the scaffold automatically adjust content when the keyboard pops up
        resizeToAvoidBottomInset: true,

        body: SafeArea(
          // Ensure we don't draw under notches or home indicators by default
          child: LayoutBuilder(
            builder: (context, constraints) {
              // On very large screens (tablets, web), constrain the content width
              // so it doesn't stretch infinitely.
              final double maxWidth = 1000.0;
              final bool needsConstraint = constraints.maxWidth > maxWidth;

              Widget content = body;

              if (showPadding) {
                content = Padding(
                  padding: DSSpacing.paddingAllM,
                  child: content,
                );
              }

              if (needsConstraint) {
                return Center(
                  child: SizedBox(
                    width: maxWidth,
                    child: content,
                  ),
                );
              }

              // Normal mobile viewport
              return content;
            },
          ),
        ),
      ),
    );
  }
}
