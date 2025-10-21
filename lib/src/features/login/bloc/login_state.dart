part of 'login_bloc.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.email = const Email.pure(),
    this.isValidLogin = false,
    this.isValidSignup = false,
    this.errorMessage,
    this.informationMessage,
  });

  final FormzSubmissionStatus status;
  final Username username;
  final Password password;
  final Email email;
  final bool isValidLogin;
  final bool isValidSignup;
  final String? errorMessage;
  final String? informationMessage;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Username? username,
    Password? password,
    Email? email,
    bool? isValidLogin,
    bool? isValidSignup,
    String? errorMessage,
    String? informationMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      isValidLogin: isValidLogin ?? this.isValidLogin,
      isValidSignup: isValidSignup ?? this.isValidSignup,
      errorMessage: errorMessage ?? this.errorMessage,
      informationMessage: informationMessage ?? this.informationMessage,
    );
  }

  @override
  List<Object> get props => [status, username, password, email];
}
