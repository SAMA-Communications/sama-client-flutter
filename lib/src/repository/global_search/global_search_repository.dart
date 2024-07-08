import '../../api/api.dart' as api;
import 'dart:async';

import '../../features/search/models/search_result.dart';


class GlobalSearchRepository {

  Future<SearchResult> search(String term) async {
    // final List<api.Chat> chats = await api.fetchChatsByName(term);
    // final List<api.User> users = await api.fetchUsersByName(term);

    List<dynamic> responses = await Future.wait([api.fetchChatsByName(term), api.fetchUsersByLogin(term)]);

    SearchResult result = SearchResult.fromJson(responses);
    return result;
  }
}