import '../../api/api.dart' as api;
import 'dart:async';

import '../../api/api.dart';
import '../../db/local/conversation_local_datasource.dart';
import '../../db/models/models.dart';
import '../../features/search/models/models.dart';

class GlobalSearchRepository {
  // final ConversationRemoteDataSource remoteDataSource;
  final ConversationLocalDatasource localDataSource;

  GlobalSearchRepository({
    // required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<SearchResult> search(String term) async {
    final List<User> users = await api.searchUsersByKeyword(term);
    final List<String> ids = await api.searchConversationsIdsByName(term);
    final List<ConversationModel> conversations =
        await localDataSource.getConversationsLocal(ids);
    return SearchResult.from(
        users.map((element) => element.toUserModel()).toList(), conversations);
  }
}
