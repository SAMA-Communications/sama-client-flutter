import '../../shared/errors/exceptions.dart';
import '../db_service.dart';
import '../models/message_model.dart';

class MessageLocalDatasource {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<MessageModel>> getAllMessagesLocal(String cid) async {
    print('getAllMessagesLocal');
    try {
      return await _databaseService.getAllMessagesLocal(cid);
    } catch (e) {
      print('getAllMessagesLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<MessageModel?> getMessageLocal(String id) async {
    print('getMessageLocal id= $id');
    try {
      return await _databaseService.getMessageLocal(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<List<MessageModel>> getMessagesLocal(List<String> ids) async {
    try {
      return await _databaseService.getMessagesLocal(ids);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> saveMessagesLocal(List<MessageModel> items) async {
    print('saveMessagesLocal');
    try {
      return await _databaseService.saveMessagesLocal(items);
    } catch (e) {
      print('saveMessagesLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }
}
