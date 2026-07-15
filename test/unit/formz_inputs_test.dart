import 'package:flutter_test/flutter_test.dart';
import 'package:login_system_flutter/features/auth/presentation/formz/auth_inputs.dart';

void main() {
  group('Email', () {
    test('empty is invalid with empty error', () {
      const email = Email.dirty('');
      expect(email.isValid, isFalse);
      expect(email.error, EmailError.empty);
    });

    test('malformed is invalid', () {
      const email = Email.dirty('not-an-email');
      expect(email.error, EmailError.invalid);
    });

    test('well-formed is valid', () {
      const email = Email.dirty('user@example.com');
      expect(email.isValid, isTrue);
      expect(email.error, isNull);
    });
  });

  group('Password', () {
    test('short password is invalid', () {
      const password = Password.dirty('abc');
      expect(password.error, PasswordError.tooShort);
    });

    test('8+ chars is valid', () {
      const password = Password.dirty('abcd1234');
      expect(password.isValid, isTrue);
    });

    test('strength scales from weak to strong', () {
      expect(const Password.dirty('abcdefgh').strength, PasswordStrength.weak);
      expect(
        const Password.dirty('Abcd1234').strength,
        PasswordStrength.medium,
      );
      expect(
        const Password.dirty('Abcd1234!xyz').strength,
        PasswordStrength.strong,
      );
    });
  });

  group('ConfirmedPassword', () {
    test('mismatch is invalid', () {
      const confirmed =
          ConfirmedPassword.dirty(password: 'abcd1234', value: 'different');
      expect(confirmed.error, ConfirmedPasswordError.mismatch);
    });

    test('match is valid', () {
      const confirmed =
          ConfirmedPassword.dirty(password: 'abcd1234', value: 'abcd1234');
      expect(confirmed.isValid, isTrue);
    });
  });

  group('Phone', () {
    test('accepts E.164-ish numbers', () {
      expect(const Phone.dirty('+15551234567').isValid, isTrue);
    });

    test('rejects letters', () {
      expect(const Phone.dirty('abc123').isValid, isFalse);
    });
  });
}
