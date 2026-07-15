import 'package:login_system_flutter/core/errors/failures.dart';
import 'package:login_system_flutter/core/utils/result.dart';
import 'package:login_system_flutter/features/auth/domain/entities/auth_tokens.dart';
import 'package:login_system_flutter/features/auth/domain/entities/user.dart';
import 'package:login_system_flutter/features/auth/domain/repositories/auth_repository.dart';

const tUser = User(id: 'u1', email: 'test@example.com', name: 'Tester');
const tTokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');
const tSession = AuthSession(user: tUser, tokens: tTokens);

/// Configurable in-memory [AuthRepository] for tests — no mocking framework.
class FakeAuthRepository implements AuthRepository {
  Result<AuthSession> loginResult = const Success(tSession);
  Result<AuthSession> registerResult = const Success(tSession);
  Result<AuthSession> googleResult = const Success(tSession);
  Result<AuthSession> appleResult = const Success(tSession);
  Result<AuthSession> otpResult = const Success(tSession);
  Result<void> sendOtpResult = const Success(null);
  Result<User> checkResult = const Success(tUser);
  Result<User> biometricResult = const Success(tUser);
  Result<void> forgotResult = const Success(null);
  Result<void> resetResult = const Success(null);
  bool biometricAvailable = true;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async =>
      loginResult;

  @override
  Future<Result<AuthSession>> register({
    required String email,
    required String password,
    String? name,
  }) async =>
      registerResult;

  @override
  Future<Result<AuthSession>> loginWithGoogle() async => googleResult;

  @override
  Future<Result<AuthSession>> loginWithApple() async => appleResult;

  @override
  Future<Result<void>> sendOtp(String phoneNumber) async => sendOtpResult;

  @override
  Future<Result<AuthSession>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async =>
      otpResult;

  @override
  Future<Result<AuthTokens>> refreshToken() async => const Success(tTokens);

  @override
  Future<Result<void>> forgotPassword(String email) async => forgotResult;

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async =>
      resetResult;

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<User>> checkAuthStatus() async => checkResult;

  @override
  Future<Result<User>> loginWithBiometrics() async => biometricResult;

  @override
  Future<bool> isBiometricAvailable() async => biometricAvailable;
}
