// =============================================================================
// NexaStays Design System — Motion
// =============================================================================
// Mirrors nexastays_web/lib/motion.ts. Prefer these over ad-hoc durations.
// Respect reduced-motion preferences in animated widgets.
// =============================================================================

import 'package:flutter/animation.dart';

/// Shared motion tokens for premium UI.
class DSMotion {
  DSMotion._();

  /// Seconds — button / tap press.
  static const double fast = 0.18;

  /// Seconds — default transitions.
  static const double normal = 0.22;

  /// Seconds — slower emphasis transitions.
  static const double slow = 0.28;

  /// Button / tap press scale.
  static const double pressScale = 0.95;

  /// Card hover / lift scale.
  static const double cardScale = 1.02;

  static Duration get fastDuration => Duration(milliseconds: motionMsFast);

  static Duration get normalDuration => Duration(milliseconds: motionMsNormal);

  static Duration get slowDuration => Duration(milliseconds: motionMsSlow);

  /// Sheet spring curve approximation.
  static const SpringDescription sheetSpring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 32,
  );

  /// Modal spring curve approximation.
  static const SpringDescription modalSpring = SpringDescription(
    mass: 1,
    stiffness: 320,
    damping: 28,
  );

  /// FAB spring curve approximation.
  static const SpringDescription fabSpring = SpringDescription(
    mass: 1,
    stiffness: 400,
    damping: 26,
  );
}

/// Milliseconds for [Duration] and [AnimatedContainer] transitions.
class DSMotionMs {
  DSMotionMs._();

  static const int fast = 180;
  static const int normal = 220;
  static const int slow = 280;
}

const int motionMsFast = DSMotionMs.fast;
const int motionMsNormal = DSMotionMs.normal;
const int motionMsSlow = DSMotionMs.slow;
