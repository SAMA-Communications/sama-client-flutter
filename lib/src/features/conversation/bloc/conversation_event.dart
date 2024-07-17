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

final class ParticipantsRequested extends ConversationEvent {
  const ParticipantsRequested();
}

final class _MessageReceived extends ConversationEvent {
  final ChatMessage message;

  const _MessageReceived(this.message);
}
