part of 'connection_bloc.dart';

sealed class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object> get props => [];
}

final class ConnectionStatusChanged extends ConnectionEvent {
  final ConnectionStatus status;

  const ConnectionStatusChanged(this.status);
}

final class ConnectionAuthStatusChanged extends ConnectionEvent {
  final AuthenticationStatus authStatus;

  const ConnectionAuthStatusChanged(this.authStatus);
}
