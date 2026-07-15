import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Persists tokens and the cached user, plus the "remember me" preference.
class AuthLocalDataSource {
  AuthLocalDataSource({
    required SecureStorage secureStorage,
    required LocalStorage localStorage,
  })  : _secure = secureStorage,
        _local = localStorage;

  final SecureStorage _secure;
  final LocalStorage _local;

  Future<void> persistSession({
    required UserModel user,
    required AuthTokensModel tokens,
    required bool rememberMe,
  }) async {
    await _secure.writeAccessToken(tokens.accessToken);
    await _local.setRememberMe(rememberMe);
    // Only persist the long-lived refresh token when the user opted in.
    if (rememberMe) {
      await _secure.writeRefreshToken(tokens.refreshToken);
    }
    await _secure.writeCachedUser(user.toJsonString());
  }

  Future<void> saveTokens(AuthTokensModel tokens) async {
    await _secure.writeAccessToken(tokens.accessToken);
    await _secure.writeRefreshToken(tokens.refreshToken);
  }

  Future<String?> readRefreshToken() => _secure.readRefreshToken();
  Future<String?> readAccessToken() => _secure.readAccessToken();

  Future<UserModel?> readCachedUser() async {
    final raw = await _secure.readCachedUser();
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJsonString(raw);
  }

  Future<void> cacheUser(UserModel user) =>
      _secure.writeCachedUser(user.toJsonString());

  bool get rememberMe => _local.rememberMe;
  bool get biometricEnabled => _local.biometricEnabled;
  Future<void> setBiometricEnabled(bool value) =>
      _local.setBiometricEnabled(value);

  Future<void> clear() async {
    await _secure.clearAll();
    await _local.setRememberMe(false);
    await _local.setBiometricEnabled(false);
  }
}
