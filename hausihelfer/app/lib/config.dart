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
  /// The backend serves them, so by default they come from the API server.
  static const legalBaseUrl = String.fromEnvironment('LEGAL_BASE_URL', defaultValue: apiBaseUrl);

  static const manageSubscriptionIos = 'https://apps.apple.com/account/subscriptions';
  static const manageSubscriptionAndroid = 'https://play.google.com/store/account/subscriptions';
}
