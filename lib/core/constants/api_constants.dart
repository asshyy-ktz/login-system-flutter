/// Centralised API route and configuration constants.
///
/// [baseUrl] is read from a compile-time environment define so the same binary
/// can target different backends:
///
///   flutter run --dart-define=API_BASE_URL=https://api.example.com/v1
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // OAuth
  static const String googleOAuth = '/auth/oauth/google';
  static const String appleOAuth = '/auth/oauth/apple';

  // OTP
  static const String otpSend = '/auth/otp/send';
  static const String otpVerify = '/auth/otp/verify';

  // Password
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Profile
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String uploadAvatar = '/profile/avatar';
  static const String deleteAccount = '/profile';
}
