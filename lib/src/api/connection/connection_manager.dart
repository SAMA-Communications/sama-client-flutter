import '../users/models/user.dart';

class ConnectionManager {
  ConnectionManager._();

  static final _instance = ConnectionManager._();

  static ConnectionManager get instance {
    return _instance;
  }

  User? currentUser;
  String? token;
}
