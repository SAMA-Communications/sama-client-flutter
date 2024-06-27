import '../api.dart';
import '../connection/connection.dart';

const String conversationsRequest = 'conversation_list';
const String getParticipantsByCids = 'get_participants_by_cids';

Future<List<Chat>> fetchChats([int startIndex = 0]) async {
  return SamaConnectionService.instance.sendRequest(conversationsRequest, {
  }).then((response) {
    List<Chat> chats;
    List<dynamic> items = List.of(response['conversations']);
    if (items.isEmpty) {
      chats = [];
    } else {
      chats = items.map((element) => Chat.fromJson(element)).toList();
    }
    return chats;
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