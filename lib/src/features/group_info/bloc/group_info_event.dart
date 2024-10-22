part of 'group_info_bloc.dart';

sealed class GroupInfoEvent extends Equatable {
  const GroupInfoEvent();

  @override
  List<Object> get props => [];
}

final class GroupParticipantsReceived extends GroupInfoEvent {
  const GroupParticipantsReceived(this.participants);

  final List<User> participants;

  @override
  List<Object> get props => [participants];
}

final class GroupAvatarPicked extends GroupInfoEvent {}

final class GroupNameChanged extends GroupInfoEvent {
  const GroupNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

final class GroupDescriptionChanged extends GroupInfoEvent {
  const GroupDescriptionChanged(this.description);

  final String description;

  @override
  List<Object> get props => [description];
}

final class GroupAddParticipantsAdded extends GroupInfoEvent {
  const GroupAddParticipantsAdded(this.participant);

  final User participant;

  @override
  List<Object> get props => [participant];
}

final class GroupAddParticipantsRemoved extends GroupInfoEvent {
  const GroupAddParticipantsRemoved(this.participant);

  final User participant;

  @override
  List<Object> get props => [participant];
}

final class GroupRemoveParticipants extends GroupInfoEvent {
  const GroupRemoveParticipants(this.participant);

  final User participant;

  @override
  List<Object> get props => [participant];
}

final class GroupInfoResetChanges extends GroupInfoEvent {}

final class GroupInfoSubmitted extends GroupInfoEvent {}
