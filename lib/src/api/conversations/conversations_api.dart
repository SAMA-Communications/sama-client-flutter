import '../api.dart';
import '../connection/connection.dart';

const String conversationsRequest = 'conversation_list';
const String getParticipantsByCids = 'get_participants_by_cids';
const String conversationSearch = 'conversation_search';
const String conversationCreate = 'conversation_create';

Future<List<Conversation>> fetchConversations([int startIndex = 0]) async {
  return SamaConnectionService.instance
      .sendRequest(conversationsRequest, {}).then((response) {
    List<Conversation> conversations;
    List<dynamic> items = List.of(response['conversations']);
    if (items.isEmpty) {
      conversations = [];
    } else {
      conversations =
          items.map((element) => Conversation.fromJson(element)).toList();
    }
    return conversations;
  });
}

Future<List<User>> fetchParticipants(List<String> cids) async {
  return SamaConnectionService.instance.sendRequest(getParticipantsByCids, {
    'cids': cids,
  }).then((response) {
    List<User> users;
    List<dynamic> items = List.of(response['users']);
    if (items.isEmpty) {
      users = [];
    } else {
      users = items.map((element) => User.fromJson(element)).toList();
    }
    return users;
  });
}

Future<List<String>> searchConversationsIdsByName(String name) async {
  return SamaConnectionService.instance.sendRequest(conversationSearch, {
    'name': name,
    'limit': 10,
  }).then((response) {
    return List.of(response['conversations']).cast<String>();
  });
}

Future<Conversation> createConversation(
    List<String> participants, String type, String? name) async {
  return SamaConnectionService.instance.sendRequest(conversationCreate, {
    if (name != null) 'name': name,
    'type': type,
    'participants': participants,
  }).then((response) {
    return Conversation.fromJson(response['conversation']);
  });
}
