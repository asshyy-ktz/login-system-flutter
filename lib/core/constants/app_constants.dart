/// App-wide, non-network constants: storage keys and tunables.
class AppConstants {
  AppConstants._();

  static const String appName = 'Login System';

  // Secure storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyCachedUser = 'cached_user';

  // Local (shared_preferences) keys
  static const String keyOnboardingSeen = 'onboarding_seen';
  static const String keyRememberMe = 'remember_me';
  static const String keyBiometricEnabled = 'biometric_enabled';

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Password policy
  static const int minPasswordLength = 8;
}
