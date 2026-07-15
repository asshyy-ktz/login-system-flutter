import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:login_system_flutter/core/errors/failures.dart';
import 'package:login_system_flutter/core/utils/result.dart';
import 'package:login_system_flutter/features/auth/domain/entities/auth_tokens.dart';
import 'package:login_system_flutter/features/auth/domain/usecases/auth_usecases.dart';
import 'package:login_system_flutter/features/auth/presentation/bloc/login_cubit.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAuthRepository repo;
  late LoginCubit cubit;

  setUp(() {
    repo = FakeAuthRepository();
    cubit = LoginCubit(
      login: LoginUseCase(repo),
      googleSignIn: GoogleSignInUseCase(repo),
      appleSignIn: AppleSignInUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  test('initial state is pure', () {
    expect(cubit.state.status, FormzSubmissionStatus.initial);
    expect(cubit.state.email.isPure, isTrue);
  });

  blocTest<LoginCubit, LoginState>(
    'emits validation without calling the API when the form is invalid',
    build: () => cubit,
    act: (c) {
      c.emailChanged('bad');
      c.passwordChanged('short');
      c.submit();
    },
    verify: (c) {
      expect(c.state.status, isNot(FormzSubmissionStatus.success));
      expect(c.state.email.isValid, isFalse);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'emits success and exposes the user on valid credentials',
    build: () => cubit,
    act: (c) {
      c.emailChanged('test@example.com');
      c.passwordChanged('password123');
      c.submit();
    },
    expect: () => [
      isA<LoginState>().having((s) => s.email.isValid, 'emailValid', true),
      isA<LoginState>().having((s) => s.password.isValid, 'pwValid', true),
      isA<LoginState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.inProgress),
      isA<LoginState>()
          .having((s) => s.status, 'status', FormzSubmissionStatus.success)
          .having((s) => s.user?.email, 'user', 'test@example.com'),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'emits failure with a message on invalid credentials',
    build: () {
      repo.loginResult = const Err(InvalidCredentialsFailure());
      return cubit;
    },
    act: (c) {
      c.emailChanged('test@example.com');
      c.passwordChanged('password123');
      c.submit();
    },
    verify: (c) {
      expect(c.state.status, FormzSubmissionStatus.failure);
      expect(c.state.errorMessage, isNotNull);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'google sign-in success exposes the user',
    build: () {
      repo.googleResult = const Success(
        AuthSession(user: tUser, tokens: tTokens),
      );
      return cubit;
    },
    act: (c) => c.loginWithGoogle(),
    verify: (c) {
      expect(c.state.status, FormzSubmissionStatus.success);
      expect(c.state.user, isNotNull);
    },
  );
}
