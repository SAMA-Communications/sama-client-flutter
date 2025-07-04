part of 'forward_messages_bloc.dart';

class ForwardMessagesEvent extends Equatable {
  const ForwardMessagesEvent();

  @override
  List<Object> get props => [];
}

final class ChatsToForward extends ForwardMessagesEvent {
  const ChatsToForward();
}

final class SendForwardMessage extends ForwardMessagesEvent {
  final List<ConversationModel> forwardChatsTo;
  final List<ChatMessage> forwardMessages;

  const SendForwardMessage(this.forwardChatsTo, this.forwardMessages);
}
