part of 'connection_bloc.dart';

enum ConnectionStatus { connecting, connected, disconnected, offline }

final class ConnectionState extends Equatable {
  const ConnectionState(
      {this.status = ConnectionStatus.connecting,
      AuthenticationStatus authStatus = AuthenticationStatus.unknown})
      : _authStatus = authStatus;

  final ConnectionStatus status;
  final AuthenticationStatus _authStatus;

  ConnectionState copyWith({
    ConnectionStatus? status,
    AuthenticationStatus? authStatus,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      authStatus: authStatus ?? _authStatus,
    );
  }

  @override
  List<Object> get props => [status, _authStatus];
}
