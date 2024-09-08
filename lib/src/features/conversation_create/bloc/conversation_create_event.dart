import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../api/api.dart';

sealed class ConversationCreateEvent extends Equatable {
  const ConversationCreateEvent();

  @override
  List<Object> get props => [];
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

final class ConversationGroupCreated extends ConversationCreateEvent {
  const ConversationGroupCreated(
      {required this.users,
      required this.type,
      required this.name,
      required this.avatarUrl});

  final List<User> users;
  final String type;
  final String name;
  final File? avatarUrl;

  @override
  List<Object> get props => [users];

  @override
  String toString() => 'ConversationGroupCreated { user: $users }';
}
