import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_system_flutter/core/errors/failures.dart';
import 'package:login_system_flutter/core/utils/result.dart';
import 'package:login_system_flutter/features/auth/domain/usecases/auth_usecases.dart';
import 'package:login_system_flutter/features/auth/presentation/bloc/auth_bloc.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAuthRepository repo;

  AuthBloc build() => AuthBloc(
        checkAuthStatus: CheckAuthStatusUseCase(repo),
        logout: LogoutUseCase(repo),
        biometricLogin: BiometricLoginUseCase(repo),
      );

  setUp(() => repo = FakeAuthRepository());

  blocTest<AuthBloc, AuthState>(
    'authenticates when a valid session exists',
    build: build,
    act: (b) => b.add(const AuthCheckRequested()),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.authenticated)
          .having((s) => s.user?.id, 'user', 'u1'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'is unauthenticated when no session exists',
    build: () {
      repo.checkResult = const Err(AuthFailure('no session'));
      return build();
    },
    act: (b) => b.add(const AuthCheckRequested()),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logout transitions to unauthenticated',
    build: build,
    seed: () => const AuthState.authenticated(tUser),
    act: (b) => b.add(const AuthLogoutRequested()),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'biometric failure surfaces an unauthenticated state with a message',
    build: () {
      repo.biometricResult = const Err(CancelledFailure('cancelled'));
      return build();
    },
    act: (b) => b.add(const AuthBiometricRequested()),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.unauthenticated)
          .having((s) => s.message, 'message', 'cancelled'),
    ],
  );
}
