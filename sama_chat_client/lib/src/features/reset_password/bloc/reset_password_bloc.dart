import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../repository/authentication/authentication_repository.dart';
import '../models/models.dart';

part 'reset_password_event.dart';

part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const ResetPasswordState()) {
    on<EmailChanged>(_onEmailChanged);
    on<OtpChanged>(_onOtpChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<EmailSubmitted>(_onEmailSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<PasswordSubmitted>(_onPasswordSubmitted);
    on<OnBackCurrentForm>(_onBackCurrentForm);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onEmailChanged(
    EmailChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        email: email,
        isEmailValid: Formz.validate([email]),
      ),
    );
  }

  void _onOtpChanged(
    OtpChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    final digit = event.digit.isEmpty ? 'x' : event.digit;
    final otpNumber =
        state.otp.value.replaceRange(event.index, event.index + 1, digit);
    final otp = Otp.dirty(otpNumber);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        startTimer: false,
        otp: otp,
        isOTPValid: Formz.validate([otp]),
      ),
    );
  }

  void _onPasswordChanged(
    PasswordChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    final password = Password.dirty(event.password);

    emit(
      state.copyWith(status: FormzSubmissionStatus.initial, password: password),
    );
  }

  void _onConfirmPasswordChanged(
    ConfirmPasswordChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    final confirmPassword = ConfirmPassword.dirty(
        currentPsw: state.password.value, value: event.confirmPassword);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        confirmPassword: confirmPassword,
        isPasswordValid: Formz.validate([confirmPassword]),
      ),
    );
  }

  Future<void> _onEmailSubmitted(
    EmailSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    if (state.isEmailValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      await _authenticationRepository
          .sendOtpEmail(
        state.email.value,
      )
          .then((_) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.initial,
            startTimer: true,
            currentForm: 1));
      }).catchError((onError) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: 'We could not find an account with this email'));
      });
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    if (state.isOTPValid) {
      emit(state.copyWith(
          status: FormzSubmissionStatus.initial, currentForm: 2));
    } else {
      emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'OTP is not valid'));
    }
  }

  Future<void> _onPasswordSubmitted(
    PasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    if (state.isPasswordValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      await _authenticationRepository
          .sendResetPassword(
        state.email.value,
        int.parse(state.otp.value),
        state.confirmPassword.value,
      )
          .then((_) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            startTimer: false,
            stopTimer: true,
            informationMessage: 'All done! Please login'));
      }).catchError((onError) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: 'Reset password failed'));
      });
    }
  }

  Future<void> _onBackCurrentForm(
    OnBackCurrentForm event,
    Emitter<ResetPasswordState> emit,
  ) async {
    var backForm = state.currentForm - 1;
    if (backForm >= 0) {
      emit(state.copyWith(
          status: FormzSubmissionStatus.initial,
          startTimer: false,
          isEmailValid: false,
          isOTPValid: false,
          otp: const Otp.pure(),
          currentForm: backForm));
    }
  }
}
