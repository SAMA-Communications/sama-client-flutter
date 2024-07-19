import '../../db/models/conversation.dart';

class ConversationLocalDataSource {

  List<ConversationModel>? conversations;


  List<ConversationModel> getConversations(List<String> ids ) {
  // Future<List<ConversationModel>> getConversations(List<String> ids ) {
    // return Future<List<ConversationModel>>.value(conversations);

    return conversations?.where((item) => ids.contains(item.id)).toList() ?? List.empty();
  }
}