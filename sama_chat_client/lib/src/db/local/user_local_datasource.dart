import '../../db/db_service.dart';
import '../../db/models/user_model.dart';
import '../../shared/errors/exceptions.dart';

class UserLocalDatasource {
  final DatabaseService databaseService = DatabaseService.instance;

  Future<Map<String, UserModel>> getUsersModelByIds(List<String> ids) async {
    //rename to getUsersByIds
    final users = await getUsersModelLocal(ids);
    return {for (var v in users) v.id!: v};
  }

  // Future<List<UserModel>> getUsersByCids(List<String> cids) async {
  //   try {
  //     return await databaseService.getUsersModelByCidsLocal(cids);
  //   } catch (e) {
  //     print('saveConversationLocal e ${e.toString()}');
  //     throw DatabaseException(e.toString());
  //   }
  // }

  Future<UserModel> saveUserLocal(UserModel item) async {
    try {
      return await databaseService.saveUserLocal(item);
    } catch (e) {
      print('saveUsersLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<List<UserModel>> saveUsersLocal(List<UserModel> items) async {
    try {
      return await databaseService.saveUsersLocal(items);
    } catch (e) {
      print('saveUsersLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<List<UserModel>> updateUsersLocal(List<UserModel> items) async {
    try {
      return await databaseService.saveUsersLocal(items);
    } catch (e) {
      print('updateUsersLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<UserModel> updateUserLocal(UserModel item) async {
    try {
      return await databaseService.updateUserLocal(item);
    } catch (e) {
      print('updateUserLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<List<UserModel>> getUsersModelLocal(List<String> ids) async {
    try {
      return await databaseService.getUsersModelLocal(ids);
    } catch (e) {
      print('getUsersModelLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<UserModel?> getUserLocal(String id) async {
    try {
      return await databaseService.getUserLocal(id);
    } catch (e) {
      print('getUserLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }
}
