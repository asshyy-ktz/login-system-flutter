import 'package:equatable/equatable.dart';

import 'user.dart';

/// A JWT access/refresh pair returned by the backend on authentication.
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

/// The combined result of a successful authentication: the user plus tokens.
class AuthSession extends Equatable {
  const AuthSession({required this.user, required this.tokens});

  final User user;
  final AuthTokens tokens;

  @override
  List<Object?> get props => [user, tokens];
}
