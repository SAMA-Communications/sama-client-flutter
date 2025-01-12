import 'dart:io';

import '../../features/conversations_list/conversations_list.dart';
import '../../shared/secure_storage.dart';
import '../connection/connection.dart';
import '../connection/http_request.dart';
import 'models/models.dart';

const String userCreateRequestName = 'user_create';
const String userLoginRequestName = 'user_login';
const String userLogoutRequestName = 'user_logout';
const String userEditRequestName = 'user_edit';
const String userDeleteRequestName = 'user_delete';
const String userConnectRequestName = 'connect';
const String usersGetByIdsRequestName = 'get_users_by_ids';

const String httpLoginRequestName = 'login';

Future<User> createUser({
  required String login,
  required String password,
  required String deviceId,
  String? firstName,
  String? lastName,
  String? email,
  String? phone,
}) {
  return SamaConnectionService.instance.sendRequest(userCreateRequestName, {
    'login': login,
    'password': password,
    'deviceId': deviceId,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    if (firstName != null) 'first_name': firstName,
    if (lastName != null) 'last_name': lastName,
  }).then((response) {
    return User.fromJson(response['user']);
  });
}

Future<User> loginHttp(User user) {
  return sendHTTPRequest(httpLoginRequestName, {
    'login': user.login,
    'password': user.password,
    'device_id': user.deviceId,
  }).then((response) {
    var loggedUser =
        User.fromJson(response['user']).copyWith(deviceId: user.deviceId);
    var accessToken = AccessToken.fromJson(response);
    var refreshToken = response['refreshToken'];
    SecureStorage.instance.saveAccessToken(accessToken);
    SecureStorage.instance.saveRefreshToken(refreshToken);
    return loggedUser;
  });
}

Future<bool> loginWithAccessToken(String token, String deviceId) {
  return SamaConnectionService.instance.sendRequest(userConnectRequestName, {
    'token': token,
    'device_id': deviceId,
  }).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<void> refreshToken(
    String accessToken, String refreshToken, String deviceId) async {
  return sendHTTPRequest(httpLoginRequestName, {
    'device_id': deviceId,
  }, {
    HttpHeaders.authorizationHeader: 'Bearer $accessToken',
    HttpHeaders.cookieHeader: 'refresh_token=$refreshToken'
  }).then((response) {
    var accessToken = AccessToken.fromJson(response);
    var refreshToken = response['refresh_token']?.toString() ?? '';
    SecureStorage.instance.saveAccessToken(accessToken);
    // SecureStorage.instance.saveRefreshToken(refreshToken);
  });
}

Future<User> login(User user) {
  return SamaConnectionService.instance.sendRequest(userLoginRequestName, {
    'login': user.login,
    'password': user.password,
    'deviceId': user.deviceId,
  }).then((response) {
    var loggedUser = User.fromJson(response['user']);
    return loggedUser;
  });
}

Future<bool> logout() {
  return SamaConnectionService.instance
      .sendRequest(userLogoutRequestName, {}).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<bool> signOut() {
  return SamaConnectionService.instance
      .sendRequest(userDeleteRequestName, {}).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<List<User>> getUsersByIds(Set<String> ids) {
  return SamaConnectionService.instance.sendRequest(
      usersGetByIdsRequestName, {'ids': ids.toList()}).then((response) {
    return List.of(response['users'])
        .map((user) => User.fromJson(user))
        .toList();
  });
}

Future<User> userEdit({
  String? login,
  String? currentPassword,
  String? newPassword,
  String? firstName,
  String? lastName,
  String? email,
  String? phone,
  Avatar? avatar,
}) {
  var requestData = {
    if (login?.isNotEmpty ?? false) 'login': login,
    if (email?.isNotEmpty ?? false) 'email': email,
    if (phone?.isNotEmpty ?? false) 'phone': phone,
    if (firstName?.isNotEmpty ?? false) 'first_name': firstName,
    if (lastName?.isNotEmpty ?? false) 'last_name': lastName,
    if (avatar != null) 'avatar_object': avatar.toImageObjectJson(),
  };

  if ((newPassword?.isNotEmpty ?? false) &&
      (currentPassword?.isNotEmpty ?? false)) {
    requestData['current_password'] = currentPassword;
    requestData['new_password'] = newPassword;
  }

  return SamaConnectionService.instance
      .sendRequest(userEditRequestName, requestData)
      .then((response) {
    return User.fromJson(response['user']);
  });
}

Future<List<User>> searchUsersByLogin(String login,
    [List<String>? ignoreIds]) async {
  return SamaConnectionService.instance.sendRequest("user_search", {
    'login': login,
    'ignore_ids': ignoreIds ?? [],
    'limit': 5,
  }).then((response) {
    List<User> users;
    List<dynamic> items = List.of(response['users']);
    if (items.isEmpty) {
      users = [];
    } else {
      users = items.map((element) => User.fromJson(element)).toList();
    }
    return users;
  });
}
