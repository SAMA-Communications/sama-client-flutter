part of 'reset_password_bloc.dart';

sealed class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object> get props => [];
}

final class EmailChanged extends ResetPasswordEvent {
  const EmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class OtpChanged extends ResetPasswordEvent {
  const OtpChanged(this.index, this.digit);

  final int index;
  final String digit;

  @override
  List<Object> get props => [index, digit];
}

final class PasswordChanged extends ResetPasswordEvent {
  const PasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class ConfirmPasswordChanged extends ResetPasswordEvent {
  const ConfirmPasswordChanged(this.confirmPassword);

  final String confirmPassword;

  @override
  List<Object> get props => [confirmPassword];
}

final class PasswordSubmitted extends ResetPasswordEvent {
  const PasswordSubmitted();
}

final class EmailSubmitted extends ResetPasswordEvent {
  const EmailSubmitted();
}

final class OtpSubmitted extends ResetPasswordEvent {
  const OtpSubmitted();
}

final class OnBackCurrentForm extends ResetPasswordEvent {
  const OnBackCurrentForm();
}
