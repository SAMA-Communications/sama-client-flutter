import 'dart:async';

import '../../api/api.dart';
import '../../repository/user/user_data_source.dart';

import '../../api/api.dart' as api;

class UserRepository {
  api.User? _user;
  final UserLocalDataSource localDataSource;

  UserRepository({required this.localDataSource});

  Future<api.User?> getUser() async {
    if (_user != null) return _user;

    return api.ConnectionManager.instance.currentUser;
  }

  //ToDo RP finish later
  Future<Map<String, User>?> getUsersByIds(List<String> ids) async {
    final participants = localDataSource.getUsersByIds(ids);
    // final usersNotExisted = Map.fromEntries(
    //     participants.entries.where((item) => item.value == null));
    // final idsNone = usersNotExisted.keys.toSet();
    Set<String> idsNone =
        participants.keys.where((key) => participants[key] == null).toSet();

    if (idsNone.isNotEmpty) {
      await api.getUsersByIds(idsNone).then((users) {
        participants.addEntries(users.map((user) => MapEntry(user.id!, user)));
      });
    }
  }

  Map<String, User?> getStoredUsersByCIds(List<String> ids) {
    return localDataSource.getUsersByIds(ids);
  }

}
