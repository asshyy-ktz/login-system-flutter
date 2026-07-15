part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.message,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated({String? message})
      : this._(status: AuthStatus.unauthenticated, message: message);

  final AuthStatus status;
  final User? user;
  final String? message;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user, message];
}
