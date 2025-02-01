import 'package:equatable/equatable.dart';

import '../../../db/models/conversation_model.dart';
import '../../../db/models/user_model.dart';

sealed class GlobalSearchState extends Equatable {
  const GlobalSearchState();

  @override
  List<Object> get props => [];
}

final class SearchStateEmpty extends GlobalSearchState {}

final class SearchStateLoading extends GlobalSearchState {}

final class SearchStateSuccess extends GlobalSearchState {
  const SearchStateSuccess(this.users, this.conversations);

  final List<UserModel> users;
  final List<ConversationModel> conversations;

  @override
  List<Object> get props => [users, conversations];

  @override
  String toString() =>
      'SearchStateSuccess { users: ${users.length}, conversations: ${conversations.length} }';
}

final class SearchStateError extends GlobalSearchState {
  const SearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
