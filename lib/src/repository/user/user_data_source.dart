import '../../api/api.dart';
import '../../shared/secure_storage.dart';

class UserLocalDataSource {
  final Map<String, User> _allUsers = {};
  User? _currentUser;

  Future<User> getLocalUser() async {
    _currentUser ??=
        await SecureStorage.instance.getLocalUser() ?? const User();
    return _currentUser!;
  }

  void updateLocalUser(User user) {
    SecureStorage.instance.saveLocalUserIfNeed(user);
    _currentUser = user;
  }

  void addUsersList(List<User> items) {
    _allUsers.addEntries(items.map((user) => MapEntry(user.id!, user)));
  }

  void addUser(User item) {
    if (!_allUsers.containsKey(item.id)) {
      _allUsers[item.id!] = item;
    }
  }

  void addUsers(Map<String, User> items) {
    _allUsers.addAll(items);
  }

  Map<String, User?> getUsers() {
    return Map.of(_allUsers);
  }

  Map<String, User?> getUsersByIds(List<String> ids) {
    return {for (var item in ids) item: _allUsers[item]};
  }
}
