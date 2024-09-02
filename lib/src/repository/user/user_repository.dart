import 'dart:async';

import '../../api/api.dart';
import '../../api/api.dart' as api;
import '../../repository/user/user_data_source.dart';

class UserRepository {
  User? _user;
  final UserLocalDataSource localDataSource;

  UserRepository({required this.localDataSource});

  Future<User?> getUser() async {
    if (_user != null) return _user;

    return ConnectionManager.instance.currentUser;
  }

  // TODO RP finish later
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
