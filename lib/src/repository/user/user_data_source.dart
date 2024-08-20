import '../../api/api.dart';

class UserLocalDataSource {
  final Map<String, User> _allUsers = {};

  void addUsersList(List<User> items) {
    _allUsers.addEntries(items.map((user) => MapEntry(user.id!, user)));
  }

  void addUser(User item) {
    _allUsers.putIfAbsent(item.id!, () => item);
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
