import 'dart:async';

import '../../users/models/models.dart';

typedef ConnectionTokens = ({
  AccessToken accessToken,
  RefreshToken refreshToken
});

class ConnectionManager {
  ConnectionManager._();

  static final _instance = ConnectionManager._();

  static ConnectionManager get instance {
    return _instance;
  }

  final StreamController<ConnectionTokens> _connectionManagerStreamController =
      StreamController.broadcast();

  Stream<ConnectionTokens> get connectionManagerStream =>
      _connectionManagerStreamController.stream;

  AccessToken? accessToken;
  RefreshToken? refreshToken;

  updateTokens(AccessToken accessToken, RefreshToken refreshToken) {
    _connectionManagerStreamController
        .add((accessToken: accessToken, refreshToken: refreshToken));
  }
}
