import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../formz/auth_inputs.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.rememberMe = false,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.user,
  });

  final Email email;
  final Password password;
  final bool rememberMe;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final User? user;

  bool get isValid => Formz.validate([email, password]);

  LoginState copyWith({
    Email? email,
    Password? password,
    bool? rememberMe,
    FormzSubmissionStatus? status,
    String? errorMessage,
    User? user,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props =>
      [email, password, rememberMe, status, errorMessage, user];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required LoginUseCase login,
    required GoogleSignInUseCase googleSignIn,
    required AppleSignInUseCase appleSignIn,
  })  : _login = login,
        _googleSignIn = googleSignIn,
        _appleSignIn = appleSignIn,
        super(const LoginState());

  final LoginUseCase _login;
  final GoogleSignInUseCase _googleSignIn;
  final AppleSignInUseCase _appleSignIn;

  void emailChanged(String value) {
    emit(state.copyWith(email: Email.dirty(value), status: FormzSubmissionStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(
      password: Password.dirty(value),
      status: FormzSubmissionStatus.initial,
    ));
  }

  void rememberMeChanged(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  Future<void> submit() async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    emit(state.copyWith(email: email, password: password));
    if (!Formz.validate([email, password])) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _login(
      email: email.value,
      password: password.value,
      rememberMe: state.rememberMe,
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

  Future<void> loginWithGoogle() => _social(_googleSignIn.call);
  Future<void> loginWithApple() => _social(_appleSignIn.call);

  Future<void> _social(Future<Result<AuthSession>> Function() call) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await call();
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
