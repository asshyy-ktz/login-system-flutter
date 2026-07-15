import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../domain/usecases/auth_usecases.dart';
import '../formz/auth_inputs.dart';

/// Drives both the forgot-password (send email) and reset-password screens.
class PasswordState extends Equatable {
  const PasswordState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  PasswordState copyWith({
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return PasswordState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [email, password, confirmedPassword, status, errorMessage];
}

class PasswordCubit extends Cubit<PasswordState> {
  PasswordCubit({
    required ForgotPasswordUseCase forgotPassword,
    required ResetPasswordUseCase resetPassword,
  })  : _forgotPassword = forgotPassword,
        _resetPassword = resetPassword,
        super(const PasswordState());

  final ForgotPasswordUseCase _forgotPassword;
  final ResetPasswordUseCase _resetPassword;

  void emailChanged(String value) =>
      emit(state.copyWith(email: Email.dirty(value), status: FormzSubmissionStatus.initial));

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: Password.dirty(value),
      confirmedPassword: ConfirmedPassword.dirty(
        password: value,
        value: state.confirmedPassword.value,
      ),
      status: FormzSubmissionStatus.initial,
    ));
  }

  void confirmedPasswordChanged(String value) {
    emit(state.copyWith(
      confirmedPassword: ConfirmedPassword.dirty(
        password: state.password.value,
        value: value,
      ),
      status: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> sendResetEmail() async {
    final email = Email.dirty(state.email.value);
    emit(state.copyWith(email: email));
    if (!Formz.validate([email])) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _forgotPassword(email.value);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }

  Future<void> resetPassword(String token) async {
    final password = Password.dirty(state.password.value);
    final confirmed = ConfirmedPassword.dirty(
      password: state.password.value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(password: password, confirmedPassword: confirmed));
    if (!Formz.validate([password, confirmed])) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _resetPassword(token: token, newPassword: password.value);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }
}
