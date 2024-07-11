import 'package:sama_client_flutter/src/db/models/conversation.dart';

import '../../api/api.dart' as api;
import 'dart:async';

import '../../api/api.dart';
import '../../features/search/models/search_result.dart';
import '../conversation/conversation_data_source.dart';

class GlobalSearchRepository {
  // final ConversationRemoteDataSource remoteDataSource;
  final ConversationLocalDataSource localDataSource;

  GlobalSearchRepository({
    // required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<SearchResult> search(String term) async {
    final List<User> users = await api.fetchUsersByLogin(term);
    final List<String> ids = await api.fetchConversationsIdsByName(term);
    final List<ConversationModel> conversations =
        localDataSource.getConversations(ids);

    return SearchResult.from(users, conversations);
  }
}
