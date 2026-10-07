/// Application-wide constants.
class AppConstants {
  const AppConstants._();

  static const double deliveryFee = 50.0;

  /// App name.
  static const String appName = 'AgroMarket';

  /// Maximum image upload size in bytes (5 MB).
  static const int maxImageUploadSize = 5 * 1024 * 1024;

  /// Maximum document upload size in bytes (10 MB).
  static const int maxDocumentUploadSize = 10 * 1024 * 1024;

  /// Maximum product images per listing.
  static const int maxProductImages = 5;

  /// Maximum FCM tokens stored per user.
  static const int maxFcmTokens = 5;

  /// Default page size for paginated queries.
  static const int defaultPageSize = 20;

  /// Default delivery radius in kilometers.
  static const double defaultDeliveryRadiusKm = 10.0;

  /// Minimum password length.
  static const int minPasswordLength = 8;

  /// Inventory reservation expiry in minutes.
  static const int inventoryReservationExpiryMinutes = 15;

  /// OTP resend cooldown in seconds.
  static const int emailVerificationResendCooldownSeconds = 60;

  /// Supported image MIME types.
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  /// Supported document MIME types.
  static const List<String> supportedDocumentTypes = [
    'image/jpeg',
    'image/png',
    'application/pdf',
  ];
}
