import 'dart:io';

import 'package:app_set_id/app_set_id.dart';

import '../connection/connection.dart';
import '../connection/http_request.dart';
import '../connection/managers/connection_manager.dart';
import '../conversations/models/avatar.dart';
import '../settings.dart';
import 'models/models.dart';
import 'models/refresh_token.dart';

const String userCreateRequestName = 'user_create';
const String userLoginRequestName = 'user_login';
const String userLogoutRequestName = 'user_logout';
const String userSearchRequestName = 'user_search';
const String userEditRequestName = 'user_edit';
const String userDeleteRequestName = 'user_delete';
const String userConnectRequestName = 'connect';
const String usersGetByIdsRequestName = 'get_users_by_ids';
const String userLastActivitySubscribe = 'user_last_activity_subscribe';
const String userLastActivityUnsubscribe = 'user_last_activity_unsubscribe';
const String userSendOtp = 'user_send_otp';
const String userResetPassword = 'user_reset_password';

const String httpLoginRequestName = 'login';

Future<User> createUser({
  required String login,
  required String password,
  required String email,
  required String deviceId,
  String? firstName,
  String? lastName,
  String? phone,
}) async {
  return SamaConnectionService.instance.sendRequest(userCreateRequestName, {
    'login': login,
    'password': password,
    'email': email,
    'device_id': deviceId,
    'organization_id': SamaSettings.instance.organizationId,
    if (phone != null) 'phone': phone,
    if (firstName != null) 'first_name': firstName,
    if (lastName != null) 'last_name': lastName,
  }).then((response) {
    return User.fromJson(response['user']);
  });
}

Future<(AccessToken, RefreshToken, User)> loginHttp(User user) {
  return sendSamaHTTPRequest(httpLoginRequestName, {
    'login': user.login,
    'password': user.password,
    'device_id': user.deviceId,
  }).then((response) {
    var loggedUser =
        User.fromJson(response['user']).copyWith(deviceId: user.deviceId);
    var accessToken = AccessToken.fromJson(response);
    var refreshToken = RefreshToken.fromJson(response);

    ConnectionManager.instance.accessToken = accessToken;
    ConnectionManager.instance.refreshToken = refreshToken;
    return (accessToken, refreshToken, loggedUser);
  });
}

Future<bool> loginWithToken([AccessToken? accessToken]) async {
  var deviceId = await AppSetId().getIdentifier();
  accessToken ??= ConnectionManager.instance.accessToken;

  if (accessToken!.expiredAt! < DateTime.now().millisecondsSinceEpoch) {
    print('loginWithAccessToken accessToken is expired, so refresh Token');
    final refreshToken = ConnectionManager.instance.refreshToken;
    accessToken = await _refreshToken(
        accessToken.token!, refreshToken!.token!, deviceId!);
  }
  return _loginWithAccessToken(accessToken.token!, deviceId!);
}

Future<bool> _loginWithAccessToken(String token, String deviceId) {
  return SamaConnectionService.instance.sendRequest(userConnectRequestName, {
    'token': token,
    'device_id': deviceId,
  }).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<AccessToken> _refreshToken(
    String accessToken, String refreshToken, String deviceId) async {
  return sendSamaHTTPRequest(httpLoginRequestName, {
    'device_id': deviceId,
  }, {
    HttpHeaders.cookieHeader: 'refresh_token=$refreshToken'
  }).then((response) {
    var accessToken = AccessToken.fromJson(response);
    var refreshToken = RefreshToken.fromJson(response);

    ConnectionManager.instance.accessToken = accessToken;
    ConnectionManager.instance.refreshToken = refreshToken;
    return accessToken;
  });
}

@Deprecated('old login way')
Future<User> login(User user) {
  return SamaConnectionService.instance.sendRequest(userLoginRequestName, {
    'login': user.login,
    'password': user.password,
    'device_id': user.deviceId,
  }).then((response) {
    var loggedUser = User.fromJson(response['user']);
    return loggedUser;
  });
}

Future<bool> logout() {
  return SamaConnectionService.instance
      .sendRequest(userLogoutRequestName, {})
      .timeout(logoutRequestTimeout)
      .then((response) {
        return bool.tryParse(response['success']?.toString() ?? 'false') ??
            false;
      });
}

Future<bool> signOut() {
  return SamaConnectionService.instance
      .sendRequest(userDeleteRequestName, {}).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<bool> sendOtpEmail(String email) async {
  return SamaConnectionService.instance.sendRequest(userSendOtp, {
    'email': email,
    'device_id': await AppSetId().getIdentifier(),
    'organization_id': SamaSettings.instance.organizationId,
  }).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<bool> sendResetPassword(
    String email, int token, String newPassword) async {
  return SamaConnectionService.instance.sendRequest(userResetPassword, {
    'email': email,
    'token': token,
    'new_password': newPassword,
    'device_id': await AppSetId().getIdentifier(),
    'organization_id': SamaSettings.instance.organizationId,
  }).then((response) {
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

Future<List<User>> searchUsersByKeyword(String keyword,
    [List<String>? ignoreIds]) async {
  return SamaConnectionService.instance.sendRequest(userSearchRequestName, {
    'keyword': keyword,
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

Future<int> subscribeUserLastActivity(String id) {
  return SamaConnectionService.instance
      .sendRequest(userLastActivitySubscribe, {'id': id}).then((response) {
    var status = response['last_activity'][id];
    return status;
  });
}

Future<bool> unsubscribeUserLastActivity() {
  return SamaConnectionService.instance
      .sendRequest(userLastActivityUnsubscribe, {}).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}
