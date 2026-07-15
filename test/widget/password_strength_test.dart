import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_system_flutter/features/auth/presentation/formz/auth_inputs.dart';
import 'package:login_system_flutter/features/auth/presentation/widgets/password_strength_indicator.dart';

Widget _wrap(Password password) => MaterialApp(
      home: Scaffold(
        body: PasswordStrengthIndicator(password: password),
      ),
    );

void main() {
  testWidgets('hidden when password is empty', (tester) async {
    await tester.pumpWidget(_wrap(const Password.pure()));
    expect(find.textContaining('Password strength'), findsNothing);
  });

  testWidgets('shows Weak for a simple password', (tester) async {
    await tester.pumpWidget(_wrap(const Password.dirty('abcdefgh')));
    expect(find.textContaining('Weak'), findsOneWidget);
  });

  testWidgets('shows Strong for a complex password', (tester) async {
    await tester.pumpWidget(_wrap(const Password.dirty('Abcd1234!xyz')));
    expect(find.textContaining('Strong'), findsOneWidget);
  });
}
