part of 'group_bloc.dart';

final class GroupState extends Equatable {
  const GroupState({
    this.status = FormzSubmissionStatus.initial,
    this.groupname = const Groupname.pure(),
    this.avatar = const GroupAvatar.pure(),
    this.participants = const Participants.pure(),
    this.isValid = false,
    this.errorMessage,
    this.informationMessage,
  });

  final FormzSubmissionStatus status;
  final Groupname groupname;
  final GroupAvatar avatar;
  final Participants participants;
  final bool isValid;
  final String? errorMessage;
  final String? informationMessage;

  GroupState copyWith({
    FormzSubmissionStatus? status,
    Groupname? groupname,
    GroupAvatar? avatar,
    Participants? participants,
    bool? isValid,
    String? errorMessage,
    String? informationMessage,
  }) {
    return GroupState(
      status: status ?? this.status,
      groupname: groupname ?? this.groupname,
      avatar: avatar ?? this.avatar,
      participants: participants ?? this.participants,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      informationMessage: informationMessage ?? this.informationMessage,
    );
  }

  @override
  List<Object?> get props => [status, groupname, avatar, participants];
}
