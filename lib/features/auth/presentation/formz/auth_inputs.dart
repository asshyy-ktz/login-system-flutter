import 'package:formz/formz.dart';

import '../../../../core/constants/app_constants.dart';

enum EmailError { empty, invalid }

class Email extends FormzInput<String, EmailError> {
  const Email.pure() : super.pure('');
  const Email.dirty([super.value = '']) : super.dirty();

  static final RegExp _regex =
      RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  @override
  EmailError? validator(String value) {
    if (value.isEmpty) return EmailError.empty;
    if (!_regex.hasMatch(value)) return EmailError.invalid;
    return null;
  }
}

enum PasswordStrength { weak, medium, strong }

enum PasswordError { empty, tooShort }

class Password extends FormzInput<String, PasswordError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordError? validator(String value) {
    if (value.isEmpty) return PasswordError.empty;
    if (value.length < AppConstants.minPasswordLength) {
      return PasswordError.tooShort;
    }
    return null;
  }

  /// Heuristic strength score used by the strength indicator widget.
  PasswordStrength get strength {
    var score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(value)) score++;
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

enum ConfirmedPasswordError { empty, mismatch }

class ConfirmedPassword
    extends FormzInput<String, ConfirmedPasswordError> {
  const ConfirmedPassword.pure()
      : password = '',
        super.pure('');
  const ConfirmedPassword.dirty({required this.password, String value = ''})
      : super.dirty(value);

  final String password;

  @override
  ConfirmedPasswordError? validator(String value) {
    if (value.isEmpty) return ConfirmedPasswordError.empty;
    if (value != password) return ConfirmedPasswordError.mismatch;
    return null;
  }
}

enum PhoneError { empty, invalid }

class Phone extends FormzInput<String, PhoneError> {
  const Phone.pure() : super.pure('');
  const Phone.dirty([super.value = '']) : super.dirty();

  static final RegExp _regex = RegExp(r'^\+?[1-9]\d{6,14}$');

  @override
  PhoneError? validator(String value) {
    if (value.isEmpty) return PhoneError.empty;
    if (!_regex.hasMatch(value)) return PhoneError.invalid;
    return null;
  }
}
