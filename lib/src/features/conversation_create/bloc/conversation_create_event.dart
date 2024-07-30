import 'package:equatable/equatable.dart';

import '../../../api/api.dart';

sealed class ConversationCreateEvent extends Equatable {
  const ConversationCreateEvent();
}

final class ConversationCreated extends ConversationCreateEvent {
  const ConversationCreated({required this.user, required this.type});

  final User user;
  final String type;

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'ConversationCreated { user: $user }';
}
