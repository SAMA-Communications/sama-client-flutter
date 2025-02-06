import '../../api/api.dart';
import '../../db/db_service.dart';
import '../../db/models/user_model.dart';
import '../../shared/errors/exceptions.dart';

class UserLocalDataSource {
  final DatabaseService databaseService = DatabaseService.instance;

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

  Future<Map<String, UserModel?>> getUsersModelByIds(List<String> ids) async {
    final users = await getUsersModelLocal(ids);
    return {for (var v in users) v.id!: v};
  }

  Future<List<UserModel>> saveUsersLocal(List<UserModel> items) async {
    try {
      return await databaseService.saveUsersLocal(items);
    } catch (e) {
      print('saveConversationLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<List<UserModel>> getUsersModelLocal(List<String> ids) async {
    try {
      return await databaseService.getUsersModelLocal(ids);
    } catch (e) {
      print('saveConversationLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }
}
