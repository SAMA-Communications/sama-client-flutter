import 'dart:async';

import '../../api/api.dart';
import '../../api/api.dart' as api;
import '../../repository/user/user_data_source.dart';
import '../../shared/secure_storage.dart';

class UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepository({required this.localDataSource});

  Future<User?> getLocalUser() async {
    return ConnectionManager.instance.currentUser;
  }

  Future<User> updateLocalUser(
      {String? currentPsw,
      String? newPassword,
      String? firstName,
      String? lastName,
      String? email,
      String? phone}) async {
    User result = await api.userEdit(
        currentPassword: currentPsw,
        newPassword: newPassword,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone);

    SecureStorage.instance.saveLocalUserIfNeed(result);
    ConnectionManager.instance.currentUser = result;
    return result;
  }

  //ToDo RP finish later
  Future<Map<String, User?>> getUsersByIds(List<String> ids) async {
    Map<String, User?> participants = localDataSource.getUsersByIds(ids);
    Set<String> idsNone =
        participants.keys.where((key) => participants[key] == null).toSet();

    if (idsNone.isNotEmpty) {
      await api.getUsersByIds(idsNone).then((users) {
        participants.addEntries(users.map((user) => MapEntry(user.id!, user)));
        localDataSource.addUsersList(users);
      });
    }
    return participants;
  }

  Map<String, User?> getStoredUsersByIds(List<String> ids) {
    return localDataSource.getUsersByIds(ids);
  }
}
