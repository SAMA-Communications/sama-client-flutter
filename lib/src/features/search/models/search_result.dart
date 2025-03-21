import '../../../db/models/conversation_model.dart';
import '../../../db/models/user_model.dart';

class SearchResult {
  const SearchResult({required this.users, required this.conversations});

  factory SearchResult.from(
      List<UserModel> users, List<ConversationModel> conversations) {
    return SearchResult(users: users, conversations: conversations);
  }

  final List<UserModel> users;
  final List<ConversationModel> conversations;
}
