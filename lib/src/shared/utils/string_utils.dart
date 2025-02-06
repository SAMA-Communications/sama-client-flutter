import '../../api/api.dart';
import '../../db/entity_builder.dart';
import '../../db/models/avatar_model.dart';
import '../../db/models/conversation_model.dart';
import '../../db/models/user_model.dart';

String getUserName(User? user) {
  if (user == null) return 'Deleted user';

  return (user.lastName?.isEmpty ?? true && (user.firstName?.isEmpty ?? true))
      ? user.email ?? user.login ?? 'Deleted user'
      : '${user.firstName ?? ''} ${user.lastName ?? ''}';
}

String getUserModelName(UserModel? user) {
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

String getConversationModelName(
    Conversation conversation, UserModel? owner, UserModel? opponent, User? localUser) {
  if (conversation.type! == 'g') return conversation.name!;
  var user = conversation.opponentId == localUser?.id ? owner : opponent;
  return getUserModelName(user);
}

String getSystemMessagePushBody(
    ConversationModel conversation, SystemChatMessage message, UserModel? opponent) {
  var opponentName = getUserModelName(opponent);
  return message.type == SystemChatMessageType.conversationKicked
      ? '$opponentName removed you from conversation'
      : message.type == SystemChatMessageType.conversationUpdated
          ? '$opponentName added you to conversation'
          : message.type == SystemChatMessageType.conversationCreated
              ? '$opponentName created a new conversation'
              : 'message';
}

Avatar? getConversationAvatar(
    Conversation conversation, User? owner, User? opponent, User? localUser) {
  return conversation.type == 'u'
      ? conversation.opponentId == localUser?.id
          ? owner?.avatar
          : opponent?.avatar
      : conversation.avatar;
}

AvatarModel? getConversationModelAvatar(
    Conversation conversation, UserModel? owner, UserModel? opponent, User? localUser) {
  return conversation.type == 'u'
      ? conversation.opponentId == localUser?.id
      ? owner?.avatar
      : opponent?.avatar
      : buildWithAvatar(conversation.avatar);
}

// set opponent always as real opponent for current user
User? getConversationOpponent(User? owner, User? opponent, User? localUser) {
  return opponent == null
      ? null
      : opponent.id == localUser?.id
          ? owner
          : opponent;
}

// set opponent always as real opponent for current user
UserModel? getConversationModelOpponent (UserModel? owner, UserModel? opponent, User? localUser) {
  return opponent == null
      ? null
      : opponent.id == localUser?.id
          ? owner
          : opponent;
}

bool isDeletedUserModel(UserModel? user) =>
    user == null || (user.email == null && user.login == null);
