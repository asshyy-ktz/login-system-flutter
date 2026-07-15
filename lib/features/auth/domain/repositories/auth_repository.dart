import '../../../../core/utils/result.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Contract the domain depends on; implemented in the data layer.
abstract interface class AuthRepository {
  Future<Result<AuthSession>> register({
    required String email,
    required String password,
    String? name,
  });

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<Result<AuthSession>> loginWithGoogle();

  Future<Result<AuthSession>> loginWithApple();

  Future<Result<void>> sendOtp(String phoneNumber);

  Future<Result<AuthSession>> verifyOtp({
    required String phoneNumber,
    required String code,
  });

  Future<Result<AuthTokens>> refreshToken();

  Future<Result<void>> forgotPassword(String email);

  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Result<void>> logout();

  /// Returns the cached/authenticated user if a valid session exists, else a
  /// failure. Used for auto-login on app start.
  Future<Result<User>> checkAuthStatus();

  /// Attempts a biometric unlock, refreshing the access token on success.
  Future<Result<User>> loginWithBiometrics();

  Future<bool> isBiometricAvailable();
}
