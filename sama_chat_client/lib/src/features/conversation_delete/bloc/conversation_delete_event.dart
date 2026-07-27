part of 'conversation_delete_bloc.dart';

sealed class ConversationDeleteEvent extends Equatable {
  const ConversationDeleteEvent();

  @override
  List<Object> get props => [];
}

final class ConversationDeleted extends ConversationDeleteEvent {
  const ConversationDeleted({required this.chat});

  final ConversationModel chat;

  @override
  List<Object> get props => [chat];

  @override
  String toString() => 'ConversationDeleted { chat: $chat }';
}
