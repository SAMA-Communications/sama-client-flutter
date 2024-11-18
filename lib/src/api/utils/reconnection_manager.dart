import 'dart:async';

import 'package:app_set_id/app_set_id.dart';

import '../../shared/secure_storage.dart';
import '../api.dart';

const int reconnectionTimeout = 5;

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
        if (SamaConnectionService.instance.connectionState ==
            ConnectionState.failed) {
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
            if (ConnectionManager.instance.token != null) {
              var deviceId = await AppSetId().getIdentifier();
              loginWithToken(ConnectionManager.instance.token!, deviceId ?? '')
                  .then((_) {
                SamaConnectionService.instance.resendAwaitingRequests();
              }).catchError((onError) async {
                if (onError is ResponseException) {
                  final user = await SecureStorage.instance.getLocalUser();
                  login(user!).then((_) {
                    SamaConnectionService.instance.resendAwaitingRequests();
                  });
                }
              });
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
