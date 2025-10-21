import '../../api/api.dart' as api;
import 'dart:async';

import '../../api/api.dart';
import '../../db/models/models.dart';
import '../../features/search/models/models.dart';
import '../conversation/conversation_repository.dart';
import '../user/user_repository.dart';

class GlobalSearchRepository {
  final ConversationRepository conversationRepository;
  final UserRepository userRepository;

  GlobalSearchRepository({
    required this.conversationRepository,
    required this.userRepository,
  });

  Future<SearchResult> search(String term) async {
    final List<User> users = await api.searchUsersByKeyword(term);
    final List<String> ids = await api.searchConversationsIdsByName(term);
    final List<ConversationModel> conversations =
        await conversationRepository.getConversationsByIds(ids);
    final List<UserModel> userModels = await userRepository
        .updateUsers(users.map((element) => element.toUserModel()).toList());
    return SearchResult.from(userModels, conversations);
  }
}
