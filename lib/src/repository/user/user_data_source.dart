import '../../api/api.dart';

class UserLocalDataSource {
  Map<String, User> allUsers = {};

  void updateUsers(List<User> users) {
    allUsers.addEntries(users.map((user) => MapEntry(user.id!, user)));
  }

  Map<String, User?> getUsers() {
    return Map.of(allUsers);
  }

  Map<String, User?> getUsersByIds(List<String> ids) {
    return {for (var item in ids) item: allUsers[item]};
  }
}
