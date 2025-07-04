part of 'conversation_bloc.dart';

sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

final class MessagesRequested extends ConversationEvent {
  final bool refresh;

  const MessagesRequested({this.refresh = false});
}

final class MessagesMoreRequested extends ConversationEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const MessagesMoreRequested({this.startDate, this.endDate});
}

final class _MessageReceived extends ConversationEvent {
  final ChatMessage message;

  const _MessageReceived(this.message);
}

final class _PendingStatusReceived extends ConversationEvent {
  final PendingMessageStatus status;

  const _PendingStatusReceived(this.status);
}

final class _SentStatusReceived extends ConversationEvent {
  final SentMessageStatus status;

  const _SentStatusReceived(this.status);
}

final class _ReadStatusReceived extends ConversationEvent {
  final ReadMessagesStatus status;

  const _ReadStatusReceived(this.status);
}

final class _FailedStatusReceived extends ConversationEvent {
  final FailedMessagesStatus status;

  const _FailedStatusReceived(this.status);
}

final class ParticipantsReceived extends ConversationEvent {
  const ParticipantsReceived();
}

final class _DraftMessageReceived extends ConversationEvent {
  const _DraftMessageReceived();
}

final class RemoveDraftMessage extends ConversationEvent {
  const RemoveDraftMessage();
}

final class _ConversationUpdated extends ConversationEvent {
  final ConversationModel conversation;

  const _ConversationUpdated(this.conversation);
}

final class ConversationDeleted extends ConversationEvent {
  const ConversationDeleted();
}

final class TypingStatusStartReceived extends ConversationEvent {
  final String from;

  const TypingStatusStartReceived(this.from);
}

final class TypingStatusStopReceived extends ConversationEvent {
  final String from;

  const TypingStatusStopReceived(this.from);
}

final class ReplyMessage extends ConversationEvent {
  final ChatMessage message;

  const ReplyMessage(this.message);
}

final class RemoveReplyMessage extends ConversationEvent {
  const RemoveReplyMessage();
}

final class ReplyMessageRequired extends ConversationEvent {
  final String msgId;
  final String replyMsgId;

  const ReplyMessageRequired(this.msgId, this.replyMsgId);
}

final class MessagesMoreForReply extends ConversationEvent {
  final String replyMsgId;

  const MessagesMoreForReply(this.replyMsgId);
}

final class RemoveMessagesMoreForReply extends ConversationEvent {
  const RemoveMessagesMoreForReply();
}

final class ChooseMessages extends ConversationEvent {
  final bool choose;
  final ChatMessage? message;

  const ChooseMessages(this.choose, {this.message});
}

final class SelectedChatsAdded extends ConversationEvent {
  final ChatMessage message;

  const SelectedChatsAdded(this.message);

  @override
  List<Object> get props => [message];
}

final class SelectedChatsRemoved extends ConversationEvent {
  final ChatMessage message;

  const SelectedChatsRemoved(this.message);

  @override
  List<Object> get props => [message];
}
