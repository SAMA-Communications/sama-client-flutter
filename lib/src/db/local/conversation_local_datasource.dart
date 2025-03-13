import '../../shared/errors/exceptions.dart';
import '../db_service.dart';
import '../models/models.dart';

class ConversationLocalDatasource {
  final DatabaseService _databaseService = DatabaseService.instance;

  // ConversationLocalDataSource(this.databaseService);

  Future<List<ConversationModel>> getAllConversationsLocal(
      {DateTime? ltDate}) async {
    print('getAllConversationsLocal');
    try {
      return await _databaseService.getAllConversationsLocal(ltDate);
    } catch (e) {
      print('getAllConversationsLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<ConversationModel?> getConversationLocal(String cid) async {
    print('getConversationLocal cid= $cid');
    try {
      return await _databaseService.getConversationLocal(cid);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<ConversationModel?> getConversationLocalByMsgId(String id) async {
    print('getConversationLocalByMsgId cid= $id');
    try {
      return await _databaseService.getConversationLocalByMsgId(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<MessageModel?> getConversationLastMessage(String id) async {
    print('getConversationLastMessage id= $id');
    try {
      return await _databaseService.getMessageLocal(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<MessageModel> updateConversationLastMessage(MessageModel item) async {
    print('updateConversationLastMessage item= $item');
    try {
      return await _databaseService.updateConversationLastMessage(item);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<List<ConversationModel>> getConversationsLocal(
      List<String> ids) async {
    try {
      return await _databaseService.getConversationsLocal(ids);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> saveConversationsLocal(List<ConversationModel> items) async {
    print('saveConversationsLocal');
    try {
      return await _databaseService.saveConversationsLocal(items);
    } catch (e) {
      print('saveConversationsLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> saveConversationLocal(ConversationModel item) async {
    print('saveConversationLocal= $item');
    try {
      return await _databaseService.saveConversationLocal(item);
    } catch (e) {
      print('saveConversationLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> updateConversationLocal(ConversationModel item) async {
    print('updateConversationLocal= $item');
    try {
      return await _databaseService.updateConversationLocal(item);
    } catch (e) {
      print('updateConversationLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> removeConversationLocal(String id) async {
    try {
      return await _databaseService.removeConversationLocal(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
