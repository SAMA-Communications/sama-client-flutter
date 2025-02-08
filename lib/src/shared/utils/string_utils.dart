import '../../api/api.dart';
import '../../db/models/models.dart';

String getUserName(UserModel? user) {
  if (user == null) return 'Deleted user';

  return (user.lastName?.isEmpty ?? true && (user.firstName?.isEmpty ?? true))
      ? user.email ?? user.login ?? 'Deleted user'
      : '${user.firstName ?? ''} ${user.lastName ?? ''}';
}

String getConversationName(Conversation conversation, UserModel? owner,
    UserModel? opponent, UserModel? localUser) {
  if (conversation.type! == 'g') return conversation.name!;
  var user = conversation.opponentId == localUser?.id ? owner : opponent;
  return getUserName(user);
}

String getSystemMessagePushBody(ConversationModel conversation,
    SystemChatMessage message, UserModel? opponent) {
  var opponentName = getUserName(opponent);
  return message.type == SystemChatMessageType.conversationKicked
      ? '$opponentName removed you from conversation'
      : message.type == SystemChatMessageType.conversationUpdated
          ? '$opponentName added you to conversation'
          : message.type == SystemChatMessageType.conversationCreated
              ? '$opponentName created a new conversation'
              : 'message';
}

AvatarModel? getConversationAvatar(Conversation conversation, UserModel? owner,
    UserModel? opponent, UserModel? localUser) {
  return conversation.type == 'u'
      ? conversation.opponentId == localUser?.id
          ? owner?.avatar
          : opponent?.avatar
      : conversation.avatar?.toAvatarModel();
}

// set opponent always as real opponent for current user
UserModel? getConversationOpponent(
    UserModel? owner, UserModel? opponent, UserModel? localUser) {
  return opponent == null
      ? null
      : opponent.id == localUser?.id
          ? owner
          : opponent;
}

bool isDeletedUser(UserModel? user) =>
    user == null || (user.email == null && user.login == null);
