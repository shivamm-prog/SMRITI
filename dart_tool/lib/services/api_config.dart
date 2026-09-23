/// Centralized API Configuration for MindSetu Flutter Frontend.
///
/// Supports:
/// - Local Development: http://127.0.0.1:8000 (default)
/// - Production Deployment: Configurable at build-time using `--dart-define=PRODUCTION_API_URL=https://...`
///   or updated at runtime via [ApiConfig.setCustomBaseUrl] / [ApiService.instance.setBaseUrl].
class ApiConfig {
  ApiConfig._();

  /// Default local development backend URL
  static const String defaultLocalUrl = 'http://127.0.0.1:8000';

  /// Compile-time environment define for production (e.g. Render, Vercel, Supabase backend)
  /// Usage: flutter build web --release --dart-define=PRODUCTION_API_URL=https://your-backend.onrender.com
  static const String _configuredProductionUrl = String.fromEnvironment(
    'PRODUCTION_API_URL',
    defaultValue: defaultLocalUrl,
  );

  static String _activeBaseUrl = _configuredProductionUrl;

  /// Returns the currently active base API URL (trimmed of trailing slashes)
  static String get baseUrl => _activeBaseUrl.replaceAll(RegExp(r'/+$'), '');

  /// Initial URL determined from environment
  static String get initialBaseUrl => _configuredProductionUrl.replaceAll(RegExp(r'/+$'), '');

  /// Checks if the application is currently pointing to local development
  static bool get isLocalDevelopment {
    final url = baseUrl.toLowerCase();
    return url.contains('localhost') || url.contains('127.0.0.1') || url.contains('10.0.2.2');
  }

  /// Sets a custom base URL dynamically at runtime (e.g. from settings or environment switch)
  static void setCustomBaseUrl(String url) {
    if (url.trim().isNotEmpty) {
      _activeBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    }
  }

  /// Resets to the compile-time configured base URL
  static void resetToDefault() {
    _activeBaseUrl = _configuredProductionUrl;
  }
}
