/// Build-time configuration. Pass values with --dart-define, e.g.
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
class AppConfig {
  static const apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080');

  /// RevenueCat public SDK keys (one per store). Empty = purchases disabled.
  static const revenueCatIosKey = String.fromEnvironment('RC_API_KEY_IOS');
  static const revenueCatAndroidKey = String.fromEnvironment('RC_API_KEY_ANDROID');
  static const premiumEntitlement = 'premium';

  /// Pages for Impressum, Datenschutz and AGB (required in Germany).
  static const legalBaseUrl =
      String.fromEnvironment('LEGAL_BASE_URL', defaultValue: 'https://hausihelfer.example');

  /// Where "Report a mistake" e-mails go.
  static const supportEmail =
      String.fromEnvironment('SUPPORT_EMAIL', defaultValue: 'support@hausihelfer.example');
}
