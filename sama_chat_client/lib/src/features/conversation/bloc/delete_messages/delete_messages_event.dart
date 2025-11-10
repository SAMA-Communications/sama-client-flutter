part of 'delete_messages_bloc.dart';

class DeleteMessagesEvent extends Equatable {
  const DeleteMessagesEvent();

  @override
  List<Object> get props => [];
}

final class DeleteMessages extends DeleteMessagesEvent {
  final Set<ChatMessage> messages;
  final DeleteMessageType type;

  const DeleteMessages(this.messages, this.type);
}