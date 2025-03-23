import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main.dart';
import '../../shared/auth/bloc/auth_bloc.dart';
import '../api.dart';

const int reconnectionTimeout = 5;
const int statusTokenExpired = 422;

class ReconnectionManager {
  ReconnectionManager._();

  static final _instance = ReconnectionManager._();

  static ReconnectionManager get instance {
    return _instance;
  }

  Timer? _reconnectionTimer;
  bool _isReconnecting = false;

  int _reconnectionTime = 0;

  StreamSubscription<ConnectionState>? _connectionStateSubscription;
  StreamSubscription<ConnectivityState>? _networkConnectionStateSubscription;

  void init() {
    log('[ReconnectionManager][init]');
    _connectionStateSubscription ??=
        SamaConnectionService.instance.connectionStateStream.listen((state) {
      log('[ReconnectionManager]',
          stringData: 'connection state changed to $state');
      if (state == ConnectionState.failed) {
        _reconnect();
      }
    });

    _networkConnectionStateSubscription ??= ConnectivityManager
        .instance.connectivityStream
        .listen((networkConnectionState) {
      log('[ReconnectionManager]',
          stringData: 'network connection changed to $networkConnectionState');

      if (networkConnectionState == ConnectivityState.hasNetwork) {
        if (SamaConnectionService.instance.connectionState !=
            ConnectionState.connected) {
          _reconnect(force: true);
        }
      }
    });
  }

  _reconnect({bool force = false}) {
    log('[ReconnectionManager][_reconnect]',
        stringData: 'force: $force timeout: $_reconnectionTime');

    if (force) _reconnectionTime = 0;

    if (SamaConnectionService.instance.connectionState !=
        ConnectionState.disconnected) {
      _reconnectionTimer?.cancel();
      _reconnectionTimer = Timer(Duration(seconds: _reconnectionTime), () {
        if (_isReconnecting) return;

        _isReconnecting = true;
        _reconnectionTime = _reconnectionTime + reconnectionTimeout;

        SamaConnectionService.instance.reconnect().then((reconnected) async {
          if (reconnected) {
            log('[ReconnectionManager]', stringData: 'reconnected');
            _reconnectionTime = 0;
            loginWithToken().then((_) {
              SamaConnectionService.instance.resendAwaitingRequests();
            }).catchError((onError) async {
              if (onError is ResponseException) {
                loginWithToken().then((_) {
                  SamaConnectionService.instance.resendAwaitingRequests();
                }).catchError((onError) {
                  var ex = onError as ResponseException;
                  log('[ReconnectionManager]',
                      stringData: 'reconnected error ${ex.message}');
                  if (ex.status == statusTokenExpired) {
                    final context = navigatorKey.currentState?.context;
                    if (context!.mounted) {
                      context
                          .read<AuthenticationBloc>()
                          .add(AuthenticationLogoutRequested());
                    }
                  }
                });
              } else {
                log('[ReconnectionManager]',
                    stringData: 'unexpected error $onError');
              }
            });
          } else {
            _reconnect();
          }
        }).whenComplete(() {
          _isReconnecting = false;
        });
      });
    }
  }

  void destroy() {
    log('[ReconnectionManager][destroy]');
    _reconnectionTimer?.cancel();
    _connectionStateSubscription?.cancel();
    _networkConnectionStateSubscription?.cancel();
  }
}
