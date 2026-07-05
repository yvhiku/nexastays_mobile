import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device browser (or external app).
Future<void> openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open link')),
    );
  }
}

/// Public legal pages on nexastays.ma (locale-prefixed).
abstract class NexaLegalUrls {
  NexaLegalUrls._();

  static const termsEn = 'https://www.nexastays.ma/en/terms';
  static const privacyEn = 'https://www.nexastays.ma/en/privacy';
}
