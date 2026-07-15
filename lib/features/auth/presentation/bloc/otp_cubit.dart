import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

enum OtpStep { enterPhone, enterCode }

class OtpState extends Equatable {
  const OtpState({
    this.step = OtpStep.enterPhone,
    this.phone = '',
    this.code = '',
    this.status = FormzSubmissionStatus.initial,
    this.secondsRemaining = 0,
    this.errorMessage,
    this.user,
  });

  final OtpStep step;
  final String phone;
  final String code;
  final FormzSubmissionStatus status;
  final int secondsRemaining;
  final String? errorMessage;
  final User? user;

  bool get canResend => secondsRemaining == 0;

  OtpState copyWith({
    OtpStep? step,
    String? phone,
    String? code,
    FormzSubmissionStatus? status,
    int? secondsRemaining,
    String? errorMessage,
    User? user,
  }) {
    return OtpState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      code: code ?? this.code,
      status: status ?? this.status,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props =>
      [step, phone, code, status, secondsRemaining, errorMessage, user];
}

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required SendOtpUseCase sendOtp,
    required VerifyOtpUseCase verifyOtp,
  })  : _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        super(const OtpState());

  final SendOtpUseCase _sendOtp;
  final VerifyOtpUseCase _verifyOtp;
  Timer? _timer;

  void phoneChanged(String value) => emit(state.copyWith(phone: value));
  void codeChanged(String value) => emit(state.copyWith(code: value));

  Future<void> sendCode() async {
    if (state.phone.isEmpty) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Enter a valid phone number',
      ));
      return;
    }
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _sendOtp(state.phone);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          step: OtpStep.enterCode,
          status: FormzSubmissionStatus.initial,
          code: '',
        ));
        _startCountdown();
      },
    );
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    await sendCode();
  }

  Future<void> verify() async {
    if (state.code.length != AppConstants.otpLength) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Enter the ${AppConstants.otpLength}-digit code',
      ));
      return;
    }
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _verifyOtp(phoneNumber: state.phone, code: state.code);
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

  void _startCountdown() {
    _timer?.cancel();
    emit(state.copyWith(secondsRemaining: AppConstants.otpResendSeconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.secondsRemaining - 1;
      if (next <= 0) {
        timer.cancel();
        emit(state.copyWith(secondsRemaining: 0));
      } else {
        emit(state.copyWith(secondsRemaining: next));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
