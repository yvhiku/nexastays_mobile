// =============================================================================
// NexaStays Design System — Shadows
// =============================================================================
// Pink-tinted shadows matching nexastays_web tailwind boxShadow tokens.
// =============================================================================

import 'package:flutter/material.dart';

import 'colors.dart';

class DSShadows {
  DSShadows._();

  static const BoxShadow soft = BoxShadow(
    blurRadius: 24,
    offset: Offset(0, 6),
    color: Color.fromRGBO(232, 80, 122, 0.12),
  );

  static const BoxShadow card = BoxShadow(
    blurRadius: 20,
    offset: Offset(0, 4),
    color: Color.fromRGBO(26, 17, 24, 0.07),
  );

  static const BoxShadow sm = BoxShadow(
    blurRadius: 8,
    offset: Offset(0, 2),
    color: Color.fromRGBO(232, 80, 122, 0.08),
  );

  static const BoxShadow none = BoxShadow(
    color: Colors.transparent,
  );

  static List<BoxShadow> get cardShadow => [card];
  static List<BoxShadow> get elevatedShadow => [soft];
  static List<BoxShadow> get primaryShadow => [sm];
}
