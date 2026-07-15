import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:login_system_flutter/features/auth/domain/usecases/auth_usecases.dart';
import 'package:login_system_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:login_system_flutter/features/auth/presentation/bloc/login_cubit.dart';

import '../helpers/fakes.dart';

/// Exercises the login handshake the UI performs: a successful [LoginCubit]
/// submission feeds the resulting user into the app-wide [AuthBloc], which is
/// what the router reacts to.
void main() {
  test('successful login promotes the global auth state to authenticated',
      () async {
    final repo = FakeAuthRepository();

    final authBloc = AuthBloc(
      checkAuthStatus: CheckAuthStatusUseCase(repo),
      logout: LogoutUseCase(repo),
      biometricLogin: BiometricLoginUseCase(repo),
    );
    final loginCubit = LoginCubit(
      login: LoginUseCase(repo),
      googleSignIn: GoogleSignInUseCase(repo),
      appleSignIn: AppleSignInUseCase(repo),
    );

    // The page listens for a successful submission and forwards the user.
    loginCubit.stream.listen((state) {
      if (state.status.isSuccess && state.user != null) {
        authBloc.add(AuthUserChanged(state.user!));
      }
    });

    loginCubit
      ..emailChanged('test@example.com')
      ..passwordChanged('password123');
    await loginCubit.submit();

    // Allow the listener + AuthBloc event to process.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(loginCubit.state.status, FormzSubmissionStatus.success);
    expect(authBloc.state.status, AuthStatus.authenticated);
    expect(authBloc.state.user?.email, 'test@example.com');

    await loginCubit.close();
    await authBloc.close();
  });

  test('logout returns the global auth state to unauthenticated', () async {
    final repo = FakeAuthRepository();
    final authBloc = AuthBloc(
      checkAuthStatus: CheckAuthStatusUseCase(repo),
      logout: LogoutUseCase(repo),
      biometricLogin: BiometricLoginUseCase(repo),
    );

    authBloc.add(const AuthCheckRequested());
    await authBloc.stream.firstWhere((s) => s.status == AuthStatus.authenticated);

    authBloc.add(const AuthLogoutRequested());
    await authBloc.stream
        .firstWhere((s) => s.status == AuthStatus.unauthenticated);

    expect(authBloc.state.status, AuthStatus.unauthenticated);
    await authBloc.close();
  });
}
