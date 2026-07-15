import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/errors/exceptions.dart';

class GoogleCredential {
  const GoogleCredential({required this.idToken, this.email, this.name});
  final String idToken;
  final String? email;
  final String? name;
}

class AppleCredential {
  const AppleCredential({
    required this.identityToken,
    this.authorizationCode,
    this.name,
  });
  final String identityToken;
  final String? authorizationCode;
  final String? name;
}

/// Wraps the native Google/Apple SDKs, returning the tokens the backend needs.
class SocialAuthDataSource {
  SocialAuthDataSource({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  final GoogleSignIn _googleSignIn;

  Future<GoogleCredential> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const CancelledException('Google sign-in cancelled');
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw const AuthProviderException('Google did not return an ID token');
      }
      return GoogleCredential(
        idToken: idToken,
        email: account.email,
        name: account.displayName,
      );
    } on CancelledException {
      rethrow;
    } on AuthProviderException {
      rethrow;
    } catch (e) {
      throw AuthProviderException('Google sign-in failed: $e');
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Non-fatal.
    }
  }

  Future<AppleCredential> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = credential.identityToken;
      if (identityToken == null) {
        throw const AuthProviderException('Apple did not return an identity token');
      }
      final name = [credential.givenName, credential.familyName]
          .where((p) => p != null && p.isNotEmpty)
          .join(' ');
      return AppleCredential(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        name: name.isEmpty ? null : name,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const CancelledException('Apple sign-in cancelled');
      }
      throw AuthProviderException('Apple sign-in failed: ${e.message}');
    } catch (e) {
      throw AuthProviderException('Apple sign-in failed: $e');
    }
  }
}
