import '../../api/api.dart';

String getUserName(User? user) {
  if (user == null) return 'Deleted user';

  return (user.lastName?.isEmpty ?? true && (user.firstName?.isEmpty ?? true))
      ? user.email ?? user.login ?? 'Deleted user'
      : '${user.firstName ?? ''} ${user.lastName ?? ''}';
}

String getConversationName(
    Conversation conversation, User? owner, User? opponent, User? localUser) {
  if (conversation.type! == 'g') return conversation.name!;
  var user = conversation.opponentId == localUser?.id ? owner : opponent;
  return getUserName(user);
}

Avatar? getConversationAvatar(
    Conversation conversation, User? owner, User? opponent, User? localUser) {
  return conversation.type == 'u'
      ? conversation.opponentId == localUser?.id
          ? owner?.avatar
          : opponent?.avatar
      : conversation.avatar;
}

// set opponent always as real opponent for current user
User? getConversationOpponent(User? owner, User? opponent, User? localUser) {
  return opponent == null
      ? null
      : opponent == localUser
          ? owner
          : opponent;
}

bool isDeletedUser(User? user) =>
    user == null || (user.email == null && user.login == null);
