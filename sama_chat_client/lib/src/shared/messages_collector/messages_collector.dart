import 'dart:async';

import '../../api/api.dart';
import '../../repository/conversation/conversation_repository.dart';
import '../../repository/messages/messages_repository.dart';

import '../../api/connection/connection.dart' as conn;

class MessagesCollector {
  MessagesCollector._();

  static final _instance = MessagesCollector._();

  static MessagesCollector get instance {
    return _instance;
  }

  late ConversationRepository conversationRepository;
  late MessagesRepository messagesRepository;
  StreamSubscription<conn.ConnectionState>? connectionStateSubscription;
  StreamSubscription<MessageSendStatus>? statusMessagesSubscription;

  void init(ConversationRepository conversationRepository,
      MessagesRepository messagesRepository) {
    log('[MessagesCollector][init]');
    this.conversationRepository = conversationRepository;
    this.messagesRepository = messagesRepository;
    statusMessagesSubscription ??=
        messagesRepository.statusMessagesStream.listen((status) async {
      if (status is SentMessageStatus) {
        _onSentStatusReceived(status);
      }
    });

    connectionStateSubscription ??= SamaConnectionService
        .instance.connectionStateStream
        .listen((status) async {
      if (status == conn.ConnectionState.connected) {
        _collectMessagesPending();
      }
    });
  }

  void _collectMessagesPending() async {
    var messages = await messagesRepository.getMessagesLocalByStatus('pending');
    for (var message in messages) {
      await messagesRepository.resendTextMessage(message);
    }
  }

  void _onSentStatusReceived(SentMessageStatus status) async {
    var msg = await messagesRepository.getMessageLocalById(status.messageId);
    if (msg != null) {
      var msgUpdated =
          msg.copyWith(id: status.serverMessageId, rawStatus: 'sent');
      var msgLocal = await messagesRepository.updateMessageLocal(msgUpdated);
      var conversation =
          await conversationRepository.getConversationById(msgLocal.cid!);
      conversationRepository.updateConversationLocal(conversation!
          .copyWith(lastMessage: msgLocal, updatedAt: msgLocal.createdAt));
    }
  }

  void destroy() {
    statusMessagesSubscription?.cancel();
    connectionStateSubscription?.cancel();
  }
}
