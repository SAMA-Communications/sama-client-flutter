import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../api/api.dart';
import '../../../api/connection/connection.dart' as conn;

part 'connection_event.dart';

part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  StreamSubscription<conn.ConnectionState>? connectionStateSubscription;
  StreamSubscription<ConnectivityState>? networkStateSubscription;

  ConnectionBloc() : super(const ConnectionState()) {
    on<ConnectionStatusChanged>(
      _onConnectionStatusChanged,
    );

    _initConnectionState();

    connectionStateSubscription =
        SamaConnectionService.instance.connectionStateStream.listen((status) {
      switch (status) {
        case conn.ConnectionState.idle:
        case conn.ConnectionState.connecting:
          if (state.status == ConnectionStatus.offline) break;
          add(const ConnectionStatusChanged(ConnectionStatus.connecting));
          break;
        case conn.ConnectionState.connected:
          add(const ConnectionStatusChanged(ConnectionStatus.connected));
          break;
        case conn.ConnectionState.disconnected:
        case conn.ConnectionState.failed:
          if (state.status == ConnectionStatus.offline) break;
          add(const ConnectionStatusChanged(ConnectionStatus.disconnected));
          break;
      }
    });

    networkStateSubscription =
        ConnectivityManager.instance.connectivityStream.listen((networkState) {
      if (networkState == ConnectivityState.none) {
        add(const ConnectionStatusChanged(ConnectionStatus.offline));
      } else if (networkState == ConnectivityState.hasNetwork) {
        add(const ConnectionStatusChanged(ConnectionStatus.connecting));
      }
    });
  }

  Future<void> _onConnectionStatusChanged(
      ConnectionStatusChanged event, Emitter<ConnectionState> emit) async {
    return emit(state.copyWith(status: event.status));
  }

  _initConnectionState() {
    ConnectivityManager.instance
        .checkIfNetworkConnectionAvailable()
        .then((hasNetwork) {
      if (hasNetwork) {
        add(const ConnectionStatusChanged(ConnectionStatus.connecting));
      } else {
        add(const ConnectionStatusChanged(ConnectionStatus.offline));
      }
    });
  }

  @override
  Future<void> close() {
    connectionStateSubscription?.cancel();
    networkStateSubscription?.cancel();
    return super.close();
  }
}
