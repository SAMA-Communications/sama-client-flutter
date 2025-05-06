part of 'conversation_bloc.dart';

sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

final class MessagesRequested extends ConversationEvent {
  final bool force;

  const MessagesRequested({this.force = false});
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
