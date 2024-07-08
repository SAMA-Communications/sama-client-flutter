import '../../../api/api.dart';

class SearchResultItem {
  const SearchResultItem({
    required this.user,
    required this.conversation,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      user: json['user'] as User,
      conversation: json['conversation'] as Conversation,
    );
  }

  final User user;
  final Conversation conversation;
}