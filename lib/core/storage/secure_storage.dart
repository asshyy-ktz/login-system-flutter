import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Thin wrapper over [FlutterSecureStorage] for tokens and the cached user.
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const AndroidOptions _androidOptions =
      AndroidOptions(encryptedSharedPreferences: true);

  Future<void> writeAccessToken(String token) => _storage.write(
        key: AppConstants.keyAccessToken,
        value: token,
        aOptions: _androidOptions,
      );

  Future<String?> readAccessToken() => _storage.read(
        key: AppConstants.keyAccessToken,
        aOptions: _androidOptions,
      );

  Future<void> writeRefreshToken(String token) => _storage.write(
        key: AppConstants.keyRefreshToken,
        value: token,
        aOptions: _androidOptions,
      );

  Future<String?> readRefreshToken() => _storage.read(
        key: AppConstants.keyRefreshToken,
        aOptions: _androidOptions,
      );

  Future<void> writeCachedUser(String json) => _storage.write(
        key: AppConstants.keyCachedUser,
        value: json,
        aOptions: _androidOptions,
      );

  Future<String?> readCachedUser() => _storage.read(
        key: AppConstants.keyCachedUser,
        aOptions: _androidOptions,
      );

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyAccessToken, aOptions: _androidOptions);
    await _storage.delete(key: AppConstants.keyRefreshToken, aOptions: _androidOptions);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll(aOptions: _androidOptions);
  }
}
