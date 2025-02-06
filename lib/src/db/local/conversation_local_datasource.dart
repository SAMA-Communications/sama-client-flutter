import '../../shared/errors/exceptions.dart';
import '../db_service.dart';
import '../models/conversation_model.dart';

class ConversationLocalDatasource {
  final DatabaseService databaseService = DatabaseService.instance;

  // ConversationLocalDataSource(this.databaseService);

  Future<List<ConversationModel>> getAllConversationsLocal() async {
    print('getAllConversationsLocal');
    try {
      return await databaseService.getAllConversationsLocal();
    } catch (e) {
      print('getAllConversationsLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<ConversationModel?> getConversationLocal(String cid) async {
    try {
      return await databaseService.getConversationLocal(cid);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<List<ConversationModel>> getConversationsLocal(
      List<String> ids) async {
    try {
      return await databaseService.getConversationsLocal(ids);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> saveConversationsLocal(List<ConversationModel> items) async {
    print('saveConversationLocal');
    try {
      return await databaseService.saveConversationsLocal(items);
    } catch (e) {
      print('saveConversationLocal e ${e.toString()}');
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> saveConversationLocal(ConversationModel item) async {
    try {
      return await databaseService.saveConversationLocal(item);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> updateConversationLocal(ConversationModel item) async {
    try {
      return await databaseService.updateConversationLocal(item);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> removeConversationLocal(String id) async {
    try {
      return await databaseService.removeConversationLocal(id);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
