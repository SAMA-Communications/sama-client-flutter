import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api.dart';
import '../api/utils/config.dart';

const String storageUserId = "storage_user_id";
const String storageUserLogin = "storage_user_login";
const String storageUserDeviceId = "storage_user_device_id";
const String storageUserFirstName = "storage_user_first_name";
const String storageUserLastName = "storage_user_last_name";
const String storageUserPhone = "storage_user_phone";
const String storageUserEmail = "storage_user_email";
const String storageUserAvatar = "storage_user_avatar";
const String storageAccessToken = "storage_access_token";
const String storageAccessTokenExpiration = "storage_access_token_expiration";
const String storageRefreshToken = "storage_refresh_token";
const String storageSubscriptionToken = "storage_subscription_token";
const String storageEnvironmentUrl = "storage_environment_url";

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  final _storage = const FlutterSecureStorage();

  SecureStorage._internal();

  static SecureStorage get instance => _instance;

  Future<void> saveLocalUserIfNeed(User user) async {
    if (await hasLocalUser() && await localUserWasNotUpdated(user)) {
      return;
    }
    saveLocalUser(user);
  }

  Future<void> saveLocalUser(User user) async {
    if (user.id != null) {
      _storage.write(key: storageUserId, value: user.id);
    }
    if (user.login != null) {
      _storage.write(key: storageUserLogin, value: user.login);
    }
    if (user.deviceId != null) {
      _storage.write(key: storageUserDeviceId, value: user.deviceId);
    }
    if (user.firstName != null) {
      _storage.write(key: storageUserFirstName, value: user.firstName);
    }
    if (user.lastName != null) {
      _storage.write(key: storageUserLastName, value: user.lastName);
    }
    if (user.phone != null) {
      _storage.write(key: storageUserPhone, value: user.phone);
    }
    if (user.email != null) {
      _storage.write(key: storageUserEmail, value: user.email);
    }
    if (user.avatar?.imageUrl != null) {
      _storage.write(key: storageUserAvatar, value: user.avatar?.imageUrl);
    }
  }

  Future<User?> getLocalUser() async {
    String? id = await _storage.read(key: storageUserId);
    String? login = await _storage.read(key: storageUserLogin);
    String? deviceId = await _storage.read(key: storageUserDeviceId);
    String? firstName = await _storage.read(key: storageUserFirstName);
    String? lastName = await _storage.read(key: storageUserLastName);
    String? phone = await _storage.read(key: storageUserPhone);
    String? email = await _storage.read(key: storageUserEmail);
    String? avatarUrl = await _storage.read(key: storageUserAvatar);
    if (login != null) {
      return User(
          id: id,
          login: login,
          avatar: Avatar(imageUrl: avatarUrl),
          deviceId: deviceId,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          email: email);
    }
    return null;
  }

  Future<bool> hasLocalUser() async {
    return await _storage.containsKey(key: storageUserLogin);
  }

  Future<bool> localUserWasNotUpdated(User user) async {
    return await getLocalUser() == user;
  }

  Future<void> deleteLocalUser() async {
    _storage.delete(key: storageUserId);
    _storage.delete(key: storageUserLogin);
    _storage.delete(key: storageUserDeviceId);
    _storage.delete(key: storageUserFirstName);
    _storage.delete(key: storageUserLastName);
    _storage.delete(key: storageUserPhone);
    _storage.delete(key: storageUserEmail);
    _storage.delete(key: storageUserAvatar);
    _storage.delete(key: storageAccessToken);
    _storage.delete(key: storageAccessTokenExpiration);
    _storage.delete(key: storageRefreshToken);
    _storage.delete(key: storageSubscriptionToken);
    // _storage.deleteAll();
  }

  Future<void> deleteAllData() async {
    deleteLocalUser();
    _storage.delete(key: storageEnvironmentUrl);
  }

  saveAccessToken(AccessToken token) {
    _storage.write(key: storageAccessToken, value: token.token);
    _storage.write(
        key: storageAccessTokenExpiration, value: token.expiredAt.toString());
  }

  Future<AccessToken?> getAccessToken() async {
    String? token = await _storage.read(key: storageAccessToken);
    int expiredAt =
        int.parse((await _storage.read(key: storageAccessTokenExpiration))!);
    return AccessToken(token: token, expiredAt: expiredAt);
  }

  saveRefreshToken(String token) {
    _storage.write(key: storageRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: storageRefreshToken);
  }

  saveSubscriptionToken(String token) {
    _storage.write(key: storageSubscriptionToken, value: token);
  }

  Future<String?> getSubscriptionToken() {
    return _storage.read(key: storageSubscriptionToken);
  }

  saveEnvironmentType(EnvType type) {
    _storage.write(key: storageEnvironmentUrl, value: type.url);
  }

  Future<EnvType> getDevEnvironmentType() async {
    return EnvType.fromUrl(await getEnvironmentUrl());
  }

  Future<String> getEnvironmentUrl() async {
    return (await _storage.read(key: storageEnvironmentUrl)) ?? EnvType.dev.url;
  }
}
