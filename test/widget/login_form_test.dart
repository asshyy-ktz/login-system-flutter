import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_system_flutter/features/auth/domain/usecases/auth_usecases.dart';
import 'package:login_system_flutter/features/auth/presentation/bloc/login_cubit.dart';
import 'package:login_system_flutter/features/auth/presentation/widgets/custom_text_field.dart';

import '../helpers/fakes.dart';

/// A stand-in for the private _LoginView that exercises real-time validation
/// through the same [LoginCubit] the page uses.
class _TestLoginForm extends StatelessWidget {
  const _TestLoginForm();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
        return Column(
          children: [
            CustomTextField(
              label: 'Email',
              errorText: (state.email.isPure || state.email.isValid)
                  ? null
                  : 'Enter a valid email',
              onChanged: cubit.emailChanged,
            ),
            CustomTextField(
              label: 'Password',
              obscure: true,
              errorText: (state.password.isPure || state.password.isValid)
                  ? null
                  : 'At least 8 characters',
              onChanged: cubit.passwordChanged,
            ),
          ],
        );
      },
    );
  }
}

void main() {
  late LoginCubit cubit;

  setUp(() {
    final repo = FakeAuthRepository();
    cubit = LoginCubit(
      login: LoginUseCase(repo),
      googleSignIn: GoogleSignInUseCase(repo),
      appleSignIn: AppleSignInUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  Widget harness() => MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const _TestLoginForm(),
          ),
        ),
      );

  testWidgets('shows an email error for malformed input', (tester) async {
    await tester.pumpWidget(harness());

    await tester.enterText(find.byType(TextField).first, 'not-an-email');
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('clears the email error once input is valid', (tester) async {
    await tester.pumpWidget(harness());

    await tester.enterText(find.byType(TextField).first, 'bad');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'user@example.com');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsNothing);
  });

  testWidgets('shows a password length error', (tester) async {
    await tester.pumpWidget(harness());

    await tester.enterText(find.byType(TextField).at(1), 'short');
    await tester.pump();

    expect(find.text('At least 8 characters'), findsOneWidget);
  });
}
