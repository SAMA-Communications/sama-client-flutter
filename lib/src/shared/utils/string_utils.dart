import '../../api/api.dart';

String getUserName(User? user) {
  if (user == null) return 'Deleted user';

  return (user.lastName?.isEmpty ?? true && (user.firstName?.isEmpty ?? true))
      ? user.email ?? user.login ?? 'Deleted user'
      : '${user.firstName ?? ''} ${user.lastName ?? ''}';
}

String getConversationName(Conversation conversation, User? opponent,
    User? owner, String? localUserId) {
  if (conversation.type! == 'g') return conversation.name!;
  var user = conversation.opponentId == localUserId ? owner : opponent;
  return getUserName(user);
}
