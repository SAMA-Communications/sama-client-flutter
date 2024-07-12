import 'dart:async';

import 'package:app_set_id/app_set_id.dart';

import '../connection/connection.dart';
import '../connection/connection_manager.dart';
import '../users/users_api.dart';
import 'connectivity_manager.dart';
import 'logger.dart';

const int reconnectionTimeout = 5;

class ReconnectionManager {
  ReconnectionManager._();

  static final _instance = ReconnectionManager._();

  static ReconnectionManager get instance {
    return _instance;
  }

  Timer? _reconnectionTimer;
  bool _isReconnecting = false;

  int _reconnectionTime = reconnectionTimeout;

  StreamSubscription<ConnectionState>? _connectionStateSubscription;
  StreamSubscription<ConnectivityState>? _networkConnectionStateSubscription;

  void init() {
    log('[ReconnectionManager][init]');
    _connectionStateSubscription =
        SamaConnectionService.instance.connectionStateStream.listen((state) {
      log('[ReconnectionManager]',
          stringData: 'connection state changed to $state');
      if (state == ConnectionState.failed) {
        _reconnect();
      }
    });

    _networkConnectionStateSubscription = ConnectivityManager
        .instance.connectivityStream
        .listen((networkConnectionState) {
      log('[ReconnectionManager]',
          stringData: 'network connection changed to $networkConnectionState');

      if (networkConnectionState == ConnectivityState.hasNetwork) {
        _reconnect(
            force: SamaConnectionService.instance.connectionState ==
                ConnectionState.failed);
      }
    });
  }

  _reconnect({bool force = false}) {
    log('[ReconnectionManager][_reconnect]',
        stringData: '${force ? 0 : _reconnectionTime}');

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
            _reconnectionTime = reconnectionTimeout;
            if (ConnectionManager.instance.token != null) {
              var deviceId = await AppSetId().getIdentifier();
              loginWithToken(ConnectionManager.instance.token!, deviceId ?? '');
            }
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
