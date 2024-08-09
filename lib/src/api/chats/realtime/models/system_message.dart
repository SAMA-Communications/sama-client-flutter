import '../../../../api/api.dart';

abstract class SystemMessage {
  String cid;
  String? from;

  SystemMessage.fromJson(Map<String, dynamic> json)
      : cid = json['cid'],
        from = json['from'];
}

enum SystemChatMessageType {
  none,
  conversationCreated,
  conversationUpdated,
  conversationKicked
}

class SystemChatMessage extends SystemMessage {
  Conversation? conversation;
  SystemChatMessageType type = SystemChatMessageType.none;

  SystemChatMessage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    final extension = json['x'];
    if (extension['conversation_created'] != null) {
      type = SystemChatMessageType.conversationCreated;
      conversation = Conversation.fromJson(extension['conversation_created']);
    } else if (extension['conversation_updated'] != null) {
      type = SystemChatMessageType.conversationUpdated;
      conversation = Conversation.fromJson(extension['conversation_updated']);
    } else if (extension['conversationKicked'] != null) {
      type = SystemChatMessageType.conversationKicked;
      conversation = Conversation.fromJson(extension['conversationKicked']);
    }
  }
}
