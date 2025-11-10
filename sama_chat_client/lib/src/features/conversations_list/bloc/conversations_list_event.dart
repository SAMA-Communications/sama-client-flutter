part of 'conversations_list_bloc.dart';

sealed class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object> get props => [];
}

final class ConversationsFetched extends ConversationsEvent {
  final bool refresh;

  const ConversationsFetched({this.refresh = false});
}

final class ConversationsMoreFetched extends ConversationsEvent {}

final class ConversationsRefreshed extends ConversationsEvent {}

final class TypingStatusStartReceived extends ConversationsEvent {
  final String cid;
  final String from;

  const TypingStatusStartReceived(this.cid, this.from);
}

final class TypingStatusStopReceived extends ConversationsEvent {
  final String cid;
  final String from;

  const TypingStatusStopReceived(this.cid, this.from);
}
