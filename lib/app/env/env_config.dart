// =============================================================================
// NexaStays Environment Configuration
// =============================================================================
// Split backends:
//   Identity (SSO, KYC/Sumsub) — default :3001
//   Stays (listings, bookings) — default :3002
//
// Android emulator: 10.0.2.2 maps to host localhost.
// Physical device: use your PC LAN IP, e.g. 192.168.1.10
//
//   flutter run \
//     --dart-define=IDENTITY_BASE_URL=http://192.168.1.10:3001/api/v1 \
//     --dart-define=STAYS_BASE_URL=http://192.168.1.10:3002/api/v1
// =============================================================================

const String _env = String.fromEnvironment('ENV', defaultValue: 'development');

/// Use [currentEnv] from `env_bootstrap.dart` after [bootstrapEnv] runs in main.

class EnvConfig {
  const EnvConfig({
    required this.identityBaseUrl,
    required this.staysBaseUrl,
    this.enableLogging = false,
    this.stripePublicKey,
    this.mapsApiKey,
  });

  const EnvConfig.development()
      : identityBaseUrl = 'http://10.0.2.2:3001/api/v1',
        staysBaseUrl = 'http://10.0.2.2:3002/api/v1',
        enableLogging = true,
        stripePublicKey = null,
        mapsApiKey = null;

  const EnvConfig.production()
      : identityBaseUrl = 'https://identity.nexastays.com/api/v1',
        staysBaseUrl = 'https://stays.nexastays.com/api/v1',
        enableLogging = false,
        stripePublicKey = null,
        mapsApiKey = null;

  factory EnvConfig.fromDartDefine() {
    const hasIdentity = bool.hasEnvironment('IDENTITY_BASE_URL');
    const identityFromDefine = String.fromEnvironment('IDENTITY_BASE_URL');
    const hasStays = bool.hasEnvironment('STAYS_BASE_URL');
    const staysFromDefine = String.fromEnvironment('STAYS_BASE_URL');
    const hasLegacyApi = bool.hasEnvironment('API_BASE_URL');
    const legacyApi = String.fromEnvironment('API_BASE_URL');
    const hasLogging = bool.hasEnvironment('ENABLE_LOGGING');
    const loggingFromDefine = bool.fromEnvironment('ENABLE_LOGGING');

    final isProd = _env == 'production';
    final defaultIdentity = isProd
        ? 'https://identity.nexastays.com/api/v1'
        : 'http://10.0.2.2:3001/api/v1';
    final defaultStays = isProd
        ? 'https://stays.nexastays.com/api/v1'
        : 'http://10.0.2.2:3002/api/v1';

    String resolveIdentity() {
      if (hasIdentity && identityFromDefine.isNotEmpty) {
        return identityFromDefine;
      }
      if (hasLegacyApi && legacyApi.isNotEmpty) {
        return legacyApi;
      }
      return defaultIdentity;
    }

    String resolveStays() {
      if (hasStays && staysFromDefine.isNotEmpty) return staysFromDefine;
      if (hasLegacyApi && legacyApi.isNotEmpty) return legacyApi;
      return defaultStays;
    }

    return EnvConfig(
      identityBaseUrl: resolveIdentity(),
      staysBaseUrl: resolveStays(),
      enableLogging: hasLogging ? loggingFromDefine : !isProd,
      stripePublicKey: _optionalEnv('STRIPE_PUBLIC_KEY'),
      mapsApiKey: _optionalEnv('MAPS_API_KEY'),
    );
  }

  final String identityBaseUrl;
  final String staysBaseUrl;

  /// Legacy alias — points at Stays API.
  String get apiBaseUrl => staysBaseUrl;

  String get baseUrl => staysBaseUrl;

  final bool enableLogging;
  final String? stripePublicKey;
  final String? mapsApiKey;

  bool get isProduction => _env == 'production';

  @override
  String toString() =>
      'EnvConfig(env: $_env, identity: $identityBaseUrl, stays: $staysBaseUrl)';
}

String? _optionalEnv(String key) {
  switch (key) {
    case 'STRIPE_PUBLIC_KEY':
      const k = String.fromEnvironment('STRIPE_PUBLIC_KEY');
      return k.isEmpty ? null : k;
    case 'MAPS_API_KEY':
      const k = String.fromEnvironment('MAPS_API_KEY');
      return k.isEmpty ? null : k;
    default:
      return null;
  }
}
