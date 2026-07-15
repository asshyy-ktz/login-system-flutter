import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Owns the global authentication status the router reacts to.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatus,
    required LogoutUseCase logout,
    required BiometricLoginUseCase biometricLogin,
  })  : _checkAuthStatus = checkAuthStatus,
        _logout = logout,
        _biometricLogin = biometricLogin,
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthBiometricRequested>(_onBiometricRequested);
  }

  final CheckAuthStatusUseCase _checkAuthStatus;
  final LogoutUseCase _logout;
  final BiometricLoginUseCase _biometricLogin;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _checkAuthStatus();
    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  /// Called by feature blocs (login/register/otp) after a successful auth.
  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    await _logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onBiometricRequested(
    AuthBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _biometricLogin();
    result.fold(
      (failure) => emit(AuthState.unauthenticated(message: failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }
}
