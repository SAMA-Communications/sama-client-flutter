import '../../api/api.dart' as api;
import 'dart:async';

import '../../api/api.dart';
import '../../db/models/models.dart';
import '../../features/search/models/models.dart';
import '../conversation/conversation_repository.dart';

class GlobalSearchRepository {
  final ConversationRepository conversationRepository;

  GlobalSearchRepository({
    required this.conversationRepository,
  });

  Future<SearchResult> search(String term) async {
    final List<User> users = await api.searchUsersByKeyword(term);
    final List<String> ids = await api.searchConversationsIdsByName(term);
    final List<ConversationModel> conversations =
        await conversationRepository.getConversationsByIds(ids);
    return SearchResult.from(
        users.map((element) => element.toUserModel()).toList(), conversations);
  }
}
