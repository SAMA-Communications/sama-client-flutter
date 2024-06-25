import 'dart:async';

import '../../api/api.dart' as api;

class UserRepository {
  api.User? _user;

  Future<api.User?> getUser() async {
    if (_user != null) return _user;

    return api.ConnectionManager.instance.currentUser;
  }
}
