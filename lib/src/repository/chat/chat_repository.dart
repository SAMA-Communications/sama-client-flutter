import '../../api/api.dart' as api;
import '../../api/api.dart';
import '../../db/models/chat.dart';

class ChatRepository {
  List<api.Chat>? _chats;
  List<api.User>? _participants;

  Future<List<api.Chat>> getChats() async {
    //FixME RP later with storage mechanism
    if (_chats != null) return _chats!;

    return api.fetchChats();
  }

  Future<List<api.User>> getParticipants(List<String> cids) async {
    //FixME RP later with storage mechanism
    if (_participants != null) return _participants!;

    return api.fetchParticipants(cids);
  }

  Future<List<ChatModel>> getChatsWithParticipants() async {
    final List<api.Chat> chats = await getChats();
    final List<String> cids = chats.map((element) => element.id!).toList();
    final List<User> users = await getParticipants(cids);
    final List<ChatModel> result = chats.map((element) => ChatModel(id: element.id!,
        createdAt: element.createdAt!,
        updatedAt: element.updatedAt!,
        type: element.type!,
        name: element.type! == 'g' ? element.name! : null,
        opponent: users.where((user) => user.id == element.opponentId).firstOrNull,
        unreadMessagesCount: element.unreadMessagesCount,
        lastMessage: element.lastMessage)).toList();
    return result;
  }
}