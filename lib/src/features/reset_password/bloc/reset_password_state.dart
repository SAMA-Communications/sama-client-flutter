part of 'reset_password_bloc.dart';

final class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.otp = const Otp.pure(),
    this.isEmailValid = false,
    this.isOTPValid = false,
    this.isPasswordValid = false,
    this.errorMessage,
    this.informationMessage,
    this.currentForm = 0,
  });

  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final Otp otp;
  final bool isEmailValid;
  final bool isOTPValid;
  final bool isPasswordValid;
  final String? errorMessage;
  final String? informationMessage;
  final int currentForm;

  ResetPasswordState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    Otp? otp,
    bool? isEmailValid,
    bool? isOTPValid,
    bool? isPasswordValid,
    String? errorMessage,
    String? informationMessage,
    int? currentForm,
  }) {
    return ResetPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      otp: otp ?? this.otp,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isOTPValid: isOTPValid ?? this.isOTPValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      errorMessage: errorMessage ?? this.errorMessage,
      informationMessage: informationMessage ?? this.informationMessage,
      currentForm: currentForm ?? this.currentForm,
    );
  }

  @override
  List<Object> get props =>
      [status, email, password, confirmPassword, otp, currentForm];
}
