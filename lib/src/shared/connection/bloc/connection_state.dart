part of 'connection_bloc.dart';

enum ConnectionStatus { connecting, connected, disconnected, offline }

final class ConnectionState extends Equatable {
  const ConnectionState({this.status = ConnectionStatus.connecting});

  final ConnectionStatus status;

  ConnectionState copyWith({ConnectionStatus? status}) {
    return ConnectionState(status: status ?? this.status);
  }

  @override
  List<Object> get props => [status];
}
