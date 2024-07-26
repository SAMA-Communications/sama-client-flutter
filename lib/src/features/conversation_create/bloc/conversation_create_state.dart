import 'package:equatable/equatable.dart';

import '../../../db/models/conversation.dart';

sealed class ConversationCreateState extends Equatable {
  const ConversationCreateState();

  @override
  List<Object> get props => [];
}

final class ConversationCreatedLoading extends ConversationCreateState {}

final class ConversationCreatedState extends ConversationCreateState {
  const ConversationCreatedState(this.conversation);

  final ConversationModel conversation;

  @override
  List<Object> get props => [conversation];
}

final class ConversationCreatedStateError extends ConversationCreateState {
  const ConversationCreatedStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
