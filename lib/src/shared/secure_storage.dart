import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api.dart';

const String storageUserLogin = "storage_user_login";
const String storageUserPsw = "storage_user_psw";

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  final _storage = const FlutterSecureStorage();

  SecureStorage._internal();

  static SecureStorage get instance => _instance;

  Future<void> saveLocalUser(User user) async {
    if (user.login != null)
      _storage.write(key: storageUserLogin, value: user.login);
    if (user.password != null)
      _storage.write(key: storageUserPsw, value: user.password);
  }

  Future<User?> getLocalUser() async {
    String? login = await _storage.read(key: storageUserLogin);
    String? password = await _storage.read(key: storageUserPsw);
    if (login != null && password != null) {
      return User(login: login, password: password);
    }
    return null;
  }

  Future<bool> hasLocalUser() async {
    return await _storage.containsKey(key: storageUserLogin);
  }

  Future<void> deleteLocalUser() async {
    // _storage.delete(key: storageUserLogin);
    // _storage.delete(key: storageUserPsw);
    _storage.deleteAll();
  }
}
