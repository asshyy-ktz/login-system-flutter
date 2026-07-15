part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on app start to determine the initial route.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Feature blocs dispatch this after a successful login/register/otp.
class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);
  final User user;

  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthBiometricRequested extends AuthEvent {
  const AuthBiometricRequested();
}
