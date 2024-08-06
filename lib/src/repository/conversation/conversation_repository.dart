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
    conversations.removeWhere((i) => i.type == 'u' && i.lastMessage == null);
    conversations.sort((a, b) => (b.lastMessage?.createdAt ?? b.updatedAt!)
        .compareTo(a.lastMessage?.createdAt ?? a.updatedAt!));

    final List<String> cids =
        conversations.map((element) => element.id!).toList();
    final List<User> participants = await getParticipants(cids);
    Map<String, User> participantsMap = {for (var v in participants) v.id!: v};

    final List<ConversationModel> result = conversations
        .map(
          (element) => ConversationModel(
            id: element.id!,
            createdAt: element.createdAt!,
            updatedAt: element.updatedAt!,
            type: element.type!,
            name: element.type! == 'g' ? element.name! : null,
            opponent: participantsMap[element.opponentId],
            owner: participantsMap[element.ownerId],
            unreadMessagesCount: element.unreadMessagesCount,
            lastMessage: element.lastMessage,
            description: element.description,
          ),
        )
        .toList();
    localDataSource.conversations = List.of(result);
    return result;
  }

  Future<ConversationModel> createConversation(
      List<api.User> participants, String type) async {
    final Conversation conversation = await api.createConversation(
        participants.map((user) => user.id!).toList(), type);
    Map<String, User> participantsMap = {for (var v in participants) v.id!: v};

    final result = ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: conversation.type! == 'g' ? conversation.name! : null,
        opponent: participantsMap[conversation.opponentId],
        owner: participantsMap[conversation.ownerId],
        unreadMessagesCount: conversation.unreadMessagesCount,
        lastMessage: conversation.lastMessage);
    localDataSource.conversations?.add(result);
    return result;
  }
}
