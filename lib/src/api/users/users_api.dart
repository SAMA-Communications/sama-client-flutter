import '../connection/connection.dart';
import '../connection/connection_manager.dart';
import 'models/user.dart';

const String userCreateRequestName = 'user_create';
const String userLoginRequestName = 'user_login';
const String userLogoutRequestName = 'user_logout';
const String userEditRequestName = 'user_edit';
const String userDeleteRequestName = 'user_delete';

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

Future<User> login(User user) {
  return SamaConnectionService.instance.sendRequest(userLoginRequestName, {
    'login': user.login,
    'password': user.password,
    'deviceId': user.deviceId,
  }).then((response) {
    var loggedUser = User.fromJson(response['user']);
    ConnectionManager.instance.currentUser = loggedUser;
    ConnectionManager.instance.token = response['token']?.toString();
    return loggedUser;
  });
}

Future<User> loginWithToken(String token, String deviceId) {
  return SamaConnectionService.instance.sendRequest(userLoginRequestName, {
    'token': token,
    'deviceId': deviceId,
  }).then((response) {
    var loggedUser = User.fromJson(response['user']);
    ConnectionManager.instance.currentUser = loggedUser;
    ConnectionManager.instance.token = response['token']?.toString();
    return loggedUser;
  });
}

Future<bool> logout() {
  return SamaConnectionService.instance
      .sendRequest(userLogoutRequestName, {}).then((response) {
    var isSuccess =
        bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
    if (isSuccess) {
      ConnectionManager.instance.currentUser = null;
      ConnectionManager.instance.token = null;
    }

    return isSuccess;
  });
}

Future<User> edit(
  String login, {
  String? currentPassword,
  String? newPassword,
  String? firstName,
  String? lastName,
  String? email,
  String? phone,
}) {
  var requestData = {
    'login': login,
    if (email?.isNotEmpty ?? false) 'email': email,
    if (phone?.isNotEmpty ?? false) 'phone': phone,
    if (firstName?.isNotEmpty ?? false) 'first_name': firstName,
    if (lastName?.isNotEmpty ?? false) 'last_name': lastName,
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

Future<bool> delete() {
  return SamaConnectionService.instance
      .sendRequest(userDeleteRequestName, {}).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}
