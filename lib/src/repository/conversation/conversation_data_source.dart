import 'package:collection/collection.dart';
import '../../db/models/conversation.dart';

class ConversationLocalDataSource {
  final Map<String, ConversationModel> _conversations = {};

  void setConversations(Map<String, ConversationModel> items) {
    _conversations.clear();
    _conversations.addAll(items);
  }

  void addAllConversations(Map<String, ConversationModel> items) {
    _conversations.addAll(items);
  }

  void addConversation(ConversationModel item) {
    if (!_conversations.containsKey(item.id)) {
      _conversations[item.id] = item;
    }
  }

  void updateConversation(ConversationModel item) {
    _conversations[item.id] = item;
  }

  void removeConversation(String id) {
    _conversations.remove(id);
  }

  List<ConversationModel> getConversationsList() {
    return _conversations.values.toList();
  }

  Map<String, ConversationModel> getConversationsMap() {
    return Map.of(_conversations);
  }

  List<ConversationModel> getConversationsByIds(List<String> ids) {
    return {for (var v in ids) _conversations[v]}.whereNotNull().toList();
  }
}
