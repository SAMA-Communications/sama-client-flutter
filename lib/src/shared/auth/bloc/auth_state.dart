part of 'auth_bloc.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user = api.User.empty,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(api.User user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final api.User user;

  @override
  List<Object> get props => [status, user];
}
