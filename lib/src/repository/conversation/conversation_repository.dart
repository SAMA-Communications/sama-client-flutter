import '../../api/api.dart' as api;
import '../../api/api.dart';
import '../../db/models/conversation.dart';
import 'conversation_data_source.dart';

class ConversationRepository {
  final ConversationLocalDataSource localDataSource;

  ConversationRepository({
    // required this.remoteDataSource,
    required this.localDataSource,
  });


  List<api.Conversation>? _conversations;
  List<api.User>? _participants;

  Future<List<api.Conversation>> getConversations() async {
    //FixME RP later with storage mechanism
    if (_conversations != null) return _conversations!;

    return api.fetchConversations();
  }

  Future<List<api.User>> getParticipants(List<String> cids) async {
    //FixME RP later with storage mechanism
    if (_participants != null) return _participants!;

    return api.fetchParticipants(cids);
  }

  Future<List<ConversationModel>> getConversationsWithParticipants() async {
    final List<api.Conversation> conversations = await getConversations();
    final List<String> cids =
        conversations.map((element) => element.id!).toList();
    final List<User> users = await getParticipants(cids);
    final List<ConversationModel> result = conversations
        .map((element) => ConversationModel(
            id: element.id!,
            createdAt: element.createdAt!,
            updatedAt: element.updatedAt!,
            type: element.type!,
            name: element.type! == 'g' ? element.name! : null,
            opponent: users
                .where((user) => user.id == element.opponentId)
                .firstOrNull,
            unreadMessagesCount: element.unreadMessagesCount,
            lastMessage: element.lastMessage))
        .toList();
    localDataSource.conversations = List.of(result);
    return result;
  }
}
