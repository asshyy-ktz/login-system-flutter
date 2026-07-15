import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/biometric_datasource.dart';
import '../datasources/social_auth_datasource.dart';
import '../models/auth_tokens_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required SocialAuthDataSource social,
    required BiometricDataSource biometric,
  })  : _remote = remote,
        _local = local,
        _social = social,
        _biometric = biometric;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final SocialAuthDataSource _social;
  final BiometricDataSource _biometric;

  @override
  Future<Result<AuthSession>> register({
    required String email,
    required String password,
    String? name,
  }) =>
      _sessionCall(
        () => _remote.register(email: email, password: password, name: name),
        rememberMe: true,
      );

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) =>
      _sessionCall(
        () => _remote.login(email: email, password: password),
        rememberMe: rememberMe,
      );

  @override
  Future<Result<AuthSession>> loginWithGoogle() async {
    try {
      final credential = await _social.signInWithGoogle();
      return _sessionCall(
        () => _remote.oauthGoogle(credential.idToken),
        rememberMe: true,
      );
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<AuthSession>> loginWithApple() async {
    try {
      final credential = await _social.signInWithApple();
      return _sessionCall(
        () => _remote.oauthApple(
          identityToken: credential.identityToken,
          authorizationCode: credential.authorizationCode,
          name: credential.name,
        ),
        rememberMe: true,
      );
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<void>> sendOtp(String phoneNumber) async {
    try {
      await _remote.sendOtp(phoneNumber);
      return const Success(null);
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<AuthSession>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) =>
      _sessionCall(
        () => _remote.verifyOtp(phoneNumber: phoneNumber, code: code),
        rememberMe: true,
      );

  @override
  Future<Result<AuthTokens>> refreshToken() async {
    try {
      final refresh = await _local.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        return const Err(AuthFailure('No refresh token stored'));
      }
      final tokens = await _remote.refresh(refresh);
      await _local.saveTokens(tokens);
      return Success(tokens);
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _remote.forgotPassword(email);
      return const Success(null);
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remote.resetPassword(token: token, newPassword: newPassword);
      return const Success(null);
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    await _remote.logout();
    await _social.signOutGoogle();
    await _local.clear();
    return const Success(null);
  }

  @override
  Future<Result<User>> checkAuthStatus() async {
    final refresh = await _local.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      return const Err(AuthFailure('No active session'));
    }
    // Silently refresh the access token to validate the session.
    try {
      final tokens = await _remote.refresh(refresh);
      await _local.saveTokens(tokens);
      final cached = await _local.readCachedUser();
      if (cached != null) return Success(cached);
      return const Err(AuthFailure('No cached user'));
    } on NetworkException {
      // Offline: fall back to the cached user if we have one.
      final cached = await _local.readCachedUser();
      if (cached != null) return Success(cached);
      return const Err(NetworkFailure());
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  @override
  Future<Result<User>> loginWithBiometrics() async {
    if (!_local.biometricEnabled) {
      return const Err(AuthFailure('Biometric login is disabled'));
    }
    final ok = await _biometric.authenticate(reason: 'Unlock your account');
    if (!ok) return const Err(CancelledFailure('Biometric authentication failed'));
    return checkAuthStatus();
  }

  @override
  Future<bool> isBiometricAvailable() => _biometric.isAvailable();

  // --- helpers ------------------------------------------------------------

  Future<Result<AuthSession>> _sessionCall(
    Future<RemoteAuthResult> Function() call, {
    required bool rememberMe,
  }) async {
    try {
      final result = await call();
      await _local.persistSession(
        user: result.user,
        tokens: result.tokens,
        rememberMe: rememberMe,
      );
      return Success(AuthSession(user: result.user, tokens: result.tokens));
    } on Exception catch (e) {
      return Err(_mapException(e));
    }
  }

  Failure _mapException(Exception e) {
    return switch (e) {
      NetworkException() => const NetworkFailure(),
      CancelledException(:final message) => CancelledFailure(message),
      UnauthorizedException(:final message) =>
        InvalidCredentialsFailure(message),
      AuthProviderException(:final message) => AuthFailure(message),
      ServerException(:final message, :final statusCode) =>
        _mapServer(message, statusCode),
      CacheException(:final message) => CacheFailure(message),
      _ => AuthFailure(e.toString()),
    };
  }

  Failure _mapServer(String message, int? statusCode) {
    final lower = message.toLowerCase();
    if (statusCode == 423 || lower.contains('locked')) {
      return AccountLockedFailure(message);
    }
    if (statusCode == 403 || lower.contains('not verified') ||
        lower.contains('unverified')) {
      return NotVerifiedFailure(message);
    }
    if (statusCode == 400 || statusCode == 401 ||
        lower.contains('invalid') || lower.contains('credential')) {
      return InvalidCredentialsFailure(message);
    }
    return ServerFailure(message, statusCode: statusCode);
  }
}
