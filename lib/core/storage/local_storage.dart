import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Non-sensitive key/value flags backed by shared_preferences.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  bool get onboardingSeen => _prefs.getBool(AppConstants.keyOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(AppConstants.keyOnboardingSeen, value);

  bool get rememberMe => _prefs.getBool(AppConstants.keyRememberMe) ?? false;
  Future<void> setRememberMe(bool value) =>
      _prefs.setBool(AppConstants.keyRememberMe, value);

  bool get biometricEnabled =>
      _prefs.getBool(AppConstants.keyBiometricEnabled) ?? false;
  Future<void> setBiometricEnabled(bool value) =>
      _prefs.setBool(AppConstants.keyBiometricEnabled, value);

  Future<void> clear() => _prefs.clear();
}
