import '../../../api/api.dart';
import '../../../db/models/conversation.dart';

class SearchResult {
  const SearchResult({required this.users, required this.conversations});

  factory SearchResult.from(
      List<User> users, List<ConversationModel> conversations) {
    return SearchResult(users: users, conversations: conversations);
  }

  final List<User> users;
  final List<ConversationModel> conversations;
}
