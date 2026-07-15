import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../formz/auth_inputs.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.name = '',
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.user,
  });

  final String name;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final User? user;

  bool get isValid => Formz.validate([email, password, confirmedPassword]);

  RegisterState copyWith({
    String? name,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormzSubmissionStatus? status,
    String? errorMessage,
    User? user,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props =>
      [name, email, password, confirmedPassword, status, errorMessage, user];
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required RegisterUseCase register})
      : _register = register,
        super(const RegisterState());

  final RegisterUseCase _register;

  void nameChanged(String value) => emit(state.copyWith(name: value));

  void emailChanged(String value) {
    emit(state.copyWith(email: Email.dirty(value), status: FormzSubmissionStatus.initial));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
      // Re-validate the confirm field against the new password.
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

  Future<void> submit() async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final confirmed = ConfirmedPassword.dirty(
      password: state.password.value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(
      email: email,
      password: password,
      confirmedPassword: confirmed,
    ));
    if (!Formz.validate([email, password, confirmed])) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _register(
      email: email.value,
      password: password.value,
      name: state.name.isEmpty ? null : state.name,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (session) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        user: session.user,
      )),
    );
  }
}
