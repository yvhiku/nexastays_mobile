// =============================================================================
// NexaStays Connectivity Banner
// =============================================================================
// A slim animated banner that listens to network state changes via
// connectivity_plus and displays an overlay when the device goes offline.
// =============================================================================

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../design_system/tokens/colors.dart';
import '../design_system/tokens/typography.dart';

/// A network-aware banner that slides in when connectivity is lost and
/// briefly shows "Back Online" when it returns.
///
/// Place it at the top of your widget tree (e.g., inside [AppScaffold]):
///
/// ```dart
/// AppScaffold(
///   body: Column(
///     children: [
///       const ConnectivityBanner(),
///       Expanded(child: _pageContent()),
///     ],
///   ),
/// )
/// ```
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  /// Current visual state of the banner.
  _BannerState _bannerState = _BannerState.hidden;

  /// Whether the device is currently offline.
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    // Check initial status
    _connectivity.checkConnectivity().then(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final offline =
        results.contains(ConnectivityResult.none) || results.isEmpty;

    if (offline && !_isOffline) {
      // ── Just went offline ────────────────────────────────────────────
      setState(() {
        _isOffline = true;
        _bannerState = _BannerState.offline;
      });
    } else if (!offline && _isOffline) {
      // ── Just came back online ────────────────────────────────────────
      setState(() {
        _isOffline = false;
        _bannerState = _BannerState.backOnline;
      });

      // Show "Back Online" for 2 seconds, then hide
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _bannerState == _BannerState.backOnline) {
          setState(() => _bannerState = _BannerState.hidden);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVisible = _bannerState != _BannerState.hidden;
    final bool isOfflineBanner = _bannerState == _BannerState.offline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      height: isVisible ? 36.0 : 0.0,
      width: double.infinity,
      color: isOfflineBanner ? DSColors.danger : DSColors.success,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isVisible ? 1.0 : 0.0,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOfflineBanner ? Icons.wifi_off : Icons.wifi,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isOfflineBanner ? 'No Internet Connection' : 'Back Online',
                style: DSTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal state machine for the banner display.
enum _BannerState {
  hidden,
  offline,
  backOnline,
}
