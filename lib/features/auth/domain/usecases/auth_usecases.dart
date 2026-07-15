import '../../../../core/utils/result.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Each use case is a single-responsibility callable wrapping one repository
/// operation. Grouped in one file for brevity; each class is independent.

class RegisterUseCase {
  const RegisterUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
    String? name,
  }) =>
      _repo.register(email: email, password: password, name: name);
}

class LoginUseCase {
  const LoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
    required bool rememberMe,
  }) =>
      _repo.login(email: email, password: password, rememberMe: rememberMe);
}

class GoogleSignInUseCase {
  const GoogleSignInUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<AuthSession>> call() => _repo.loginWithGoogle();
}

class AppleSignInUseCase {
  const AppleSignInUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<AuthSession>> call() => _repo.loginWithApple();
}

class SendOtpUseCase {
  const SendOtpUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<void>> call(String phoneNumber) => _repo.sendOtp(phoneNumber);
}

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<AuthSession>> call({
    required String phoneNumber,
    required String code,
  }) =>
      _repo.verifyOtp(phoneNumber: phoneNumber, code: code);
}

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<AuthTokens>> call() => _repo.refreshToken();
}

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<void>> call(String email) => _repo.forgotPassword(email);
}

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<void>> call({
    required String token,
    required String newPassword,
  }) =>
      _repo.resetPassword(token: token, newPassword: newPassword);
}

class LogoutUseCase {
  const LogoutUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<void>> call() => _repo.logout();
}

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<User>> call() => _repo.checkAuthStatus();
}

class BiometricLoginUseCase {
  const BiometricLoginUseCase(this._repo);
  final AuthRepository _repo;
  Future<Result<User>> call() => _repo.loginWithBiometrics();
  Future<bool> isAvailable() => _repo.isBiometricAvailable();
}
