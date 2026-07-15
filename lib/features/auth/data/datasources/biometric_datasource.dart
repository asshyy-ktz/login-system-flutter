import 'package:local_auth/local_auth.dart';

/// Wraps [LocalAuthentication] for fingerprint / Face ID unlock.
class BiometricDataSource {
  BiometricDataSource({LocalAuthentication? localAuth})
      : _auth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Authenticate to continue'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN/passcode fallback
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
