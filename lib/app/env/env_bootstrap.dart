import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'env_config.dart';

EnvConfig? _resolvedEnv;

/// Resolved environment (call [bootstrapEnv] in main before DI).
EnvConfig get currentEnv => _resolvedEnv ?? EnvConfig.fromDartDefine();

bool _hasExplicitApiUrls() {
  const hasIdentity = bool.hasEnvironment('IDENTITY_BASE_URL');
  const identity = String.fromEnvironment('IDENTITY_BASE_URL');
  const hasStays = bool.hasEnvironment('STAYS_BASE_URL');
  const stays = String.fromEnvironment('STAYS_BASE_URL');
  const hasLegacy = bool.hasEnvironment('API_BASE_URL');
  const legacy = String.fromEnvironment('API_BASE_URL');
  return (hasIdentity && identity.isNotEmpty) ||
      (hasStays && stays.isNotEmpty) ||
      (hasLegacy && legacy.isNotEmpty);
}

/// Pick API host for local dev when no --dart-define URLs are passed.
Future<String> resolveDevApiHost() async {
  const fromDefine = String.fromEnvironment('DEV_HOST');
  if (fromDefine.isNotEmpty) return fromDefine;

  if (!kIsWeb) {
    if (Platform.isAndroid) {
      final android = await DeviceInfoPlugin().androidInfo;
      if (!android.isPhysicalDevice) return '10.0.2.2';
    } else if (Platform.isIOS) {
      final ios = await DeviceInfoPlugin().iosInfo;
      if (!ios.isPhysicalDevice) return '127.0.0.1';
    }
  }

  try {
    final raw = await rootBundle.loadString('assets/config/dev_api_host.txt');
    final host = raw.trim().split(RegExp(r'\s+')).first;
    if (host.isNotEmpty) return host;
  } catch (_) {
    // Fall through
  }

  return '10.0.2.2';
}

/// Must run before [configureDependencies] so Dio clients get the right base URLs.
Future<void> bootstrapEnv() async {
  if (_hasExplicitApiUrls()) {
    _resolvedEnv = EnvConfig.fromDartDefine();
    return;
  }

  const envName = String.fromEnvironment('ENV', defaultValue: 'development');
  if (envName == 'production') {
    _resolvedEnv = const EnvConfig.production();
    return;
  }

  final host = await resolveDevApiHost();
  _resolvedEnv = EnvConfig(
    identityBaseUrl: 'http://$host:3001/api/v1',
    staysBaseUrl: 'http://$host:3002/api/v1',
    enableLogging: true,
  );

  if (kDebugMode) {
    debugPrint('Nexa API host: $host');
    debugPrint('  identity: ${_resolvedEnv!.identityBaseUrl}');
    debugPrint('  stays:    ${_resolvedEnv!.staysBaseUrl}');
  }
}
