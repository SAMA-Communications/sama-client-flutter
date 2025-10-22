import '../../users/models/models.dart';

class ConnectionManager {
  ConnectionManager._();

  static final _instance = ConnectionManager._();

  static ConnectionManager get instance {
    return _instance;
  }

  AccessToken? accessToken;
  RefreshToken? refreshToken;
}
