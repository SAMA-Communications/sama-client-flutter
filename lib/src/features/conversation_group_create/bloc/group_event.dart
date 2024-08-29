part of 'group_bloc.dart';

sealed class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object> get props => [];
}

final class GroupnameChanged extends GroupEvent {
  const GroupnameChanged(this.groupname);

  final String groupname;

  @override
  List<Object> get props => [groupname];
}

final class GroupAvatarPicked extends GroupEvent {}

final class GroupParticipantsAdded extends GroupEvent {
  const GroupParticipantsAdded(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class GroupParticipantsRemoved extends GroupEvent {
  const GroupParticipantsRemoved(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class GroupSubmitted extends GroupEvent {}
