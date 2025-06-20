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
