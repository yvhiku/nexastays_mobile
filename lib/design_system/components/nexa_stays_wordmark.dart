import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/colors.dart';

/// Visual style for [NexaStaysWordmark] — matches nexastays_web NavBar variants.
enum NexaStaysWordmarkVariant {
  /// Light background: dark ink "Nexa" + primary pink "Stays" (default navbar).
  light,

  /// Pink / dark hero: white "Nexa" + lighter pink "Stays".
  onGradient,

  /// Fully white (e.g. solid overlays).
  onDark,
}

/// Brand wordmark: **Nexa** + **Stays** in Playfair Display, matching the website.
class NexaStaysWordmark extends StatelessWidget {
  const NexaStaysWordmark({
    super.key,
    this.fontSize = 20,
    this.fontWeight = FontWeight.w700,
    this.variant = NexaStaysWordmarkVariant.light,
    this.textAlign,
  });

  final double fontSize;
  final FontWeight fontWeight;
  final NexaStaysWordmarkVariant variant;
  final TextAlign? textAlign;

  Color get _nexaColor {
    switch (variant) {
      case NexaStaysWordmarkVariant.light:
        return DSColors.ink;
      case NexaStaysWordmarkVariant.onGradient:
        return Colors.white;
      case NexaStaysWordmarkVariant.onDark:
        return Colors.white;
    }
  }

  Color get _staysColor {
    switch (variant) {
      case NexaStaysWordmarkVariant.light:
        return DSColors.primary;
      case NexaStaysWordmarkVariant.onGradient:
        return DSColors.primaryLight;
      case NexaStaysWordmarkVariant.onDark:
        return Colors.white;
    }
  }

  TextStyle _style(Color color) => GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: 1.1,
      );

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Nexa ', style: _style(_nexaColor)),
          TextSpan(text: 'Stays', style: _style(_staysColor)),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// Logo icon + wordmark row — matches nexastays_web NavBar layout.
class NexaStaysBrandRow extends StatelessWidget {
  const NexaStaysBrandRow({
    super.key,
    this.logoSize = 36,
    this.fontSize = 20,
    this.variant = NexaStaysWordmarkVariant.light,
    this.logoAsset = 'assets/images/ui/logo.png',
  });

  final double logoSize;
  final double fontSize;
  final NexaStaysWordmarkVariant variant;
  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DSColors.primarySoft, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(logoAsset, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        NexaStaysWordmark(fontSize: fontSize, variant: variant),
      ],
    );
  }
}
