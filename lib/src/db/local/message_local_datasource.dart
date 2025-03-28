import '../../shared/errors/exceptions.dart';
import '../db_service.dart';
import '../models/message_model.dart';

class MessageLocalDatasource {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<MessageModel>> getAllMessagesLocal(String cid,
      {DateTime? ltDate}) async {
    print('getAllMessagesLocal');
    try {
      return await _databaseService.getAllMessagesLocal(cid, ltDate);
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

  Future<bool> saveMessageLocal(MessageModel item) async {
    print('saveMessageLocal= $item');
    try {
      return await _databaseService.saveMessageLocal(item);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<MessageModel> updateMessageLocal(MessageModel item) async {
    print('updateMessageLocal= $item');
    try {
      return await _databaseService.updateMessageLocal(item);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> updateMessagesLocal(List<MessageModel> items) async {
    print('updateMessagesLocal= $items');
    try {
      return await _databaseService.saveMessagesLocal(items);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
