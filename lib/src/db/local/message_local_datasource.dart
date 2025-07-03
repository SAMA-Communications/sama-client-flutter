import '../../shared/errors/exceptions.dart';
import '../db_service.dart';
import '../models/models.dart';

class MessageLocalDatasource {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<MessageModel>> getAllMessagesLocal(String cid,
      {DateTime? ltDate, int? limit}) async {
    print('getAllMessagesLocal');
    try {
      return await _databaseService.getAllMessagesLocal(cid, ltDate, limit);
    } catch (e) {
      print('getAllMessagesLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<MessageModel?> getMessageLocalById(String id) async {
    print('getMessageLocalById id= $id');
    try {
      return await _databaseService.getMessageLocal(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<MessageModel?> getMessageLocalByStatus(
      String cid, String status) async {
    print('getMessageLocalByStatus= $cid');
    try {
      return await _databaseService.getMessageLocalByStatus(cid, status);
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

  Future<List<MessageModel>> getMessagesLocalByStatus(String status) async {
    try {
      return await _databaseService.getMessagesLocalByStatus(status);
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

  Future<MessageModel> saveMessageLocal(MessageModel item) async {
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

  Future<bool> removeMessageLocal(String id) async {
    print('removeMessageLocal= $id');
    try {
      return await _databaseService.removeMessageLocal(id);
    } catch (e) {
      print('removeMessageLocal e= $id');
      throw DatabaseException(e.toString());
    }
  }

  Stream<ConversationModel?> watchedConversation(String id) {
    print('watchedConversation');
    try {
      return _databaseService.watchedConversation(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
