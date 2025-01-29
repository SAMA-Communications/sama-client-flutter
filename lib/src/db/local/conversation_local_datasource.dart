import '../../shared/errors/exceptions.dart';
import '../db_service.dart';
import '../entities/conversation_entity.dart';

class ConversationLocalDataSource {
  final DatabaseService databaseService = DatabaseService.instance;

  // ConversationLocalDataSource(this.databaseService);

  Future<List<ConversationEntity>> getAllConversationsLocal() async {
    try {
      return await databaseService.getAllConversationsLocal();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<ConversationEntity> getConversationLocal(String cid) async {
    try {
      return await databaseService.getConversationLocal(cid);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> saveConversationsLocal(List<ConversationEntity> items) async {
    try {
      return await databaseService.saveConversationsLocal(items);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  Future<bool> saveConversationLocal(ConversationEntity item) async {
    try {
      return await databaseService.saveConversationLocal(item);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
