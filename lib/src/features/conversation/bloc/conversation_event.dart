part of 'conversation_bloc.dart';

sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

final class MessagesRequested extends ConversationEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const MessagesRequested({this.startDate, this.endDate});
}

final class _MessageReceived extends ConversationEvent {
  final ChatMessage message;

  const _MessageReceived(this.message);
}

final class ParticipantsReceived extends ConversationEvent {
  const ParticipantsReceived();
}

final class _ConversationUpdated extends ConversationEvent {
  final ConversationModel conversation;

  const _ConversationUpdated(this.conversation);
}

final class ConversationDeleted extends ConversationEvent {
  const ConversationDeleted();
}
