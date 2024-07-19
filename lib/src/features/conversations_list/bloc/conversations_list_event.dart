part of 'conversations_list_bloc.dart';

sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

final class ConversationFetched extends ConversationEvent {}
