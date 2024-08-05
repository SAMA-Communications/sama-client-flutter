import 'package:sama_client_flutter/src/api/api.dart';

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
    if (json['conversation_created'] != null) {
      type = SystemChatMessageType.conversationCreated;
      conversation = json['conversation_created'];
    } else if (json['conversation_updated'] != null) {
      type = SystemChatMessageType.conversationUpdated;
      conversation = json['conversation_updated'];
    } else if (json['conversationKicked'] != null) {
      type = SystemChatMessageType.conversationKicked;
      conversation = json['conversationKicked'];
    }
  }
}
