part of 'group_info_bloc.dart';

final class GroupInfoState extends Equatable {
  const GroupInfoState({
    required this.conversation,
    this.status = FormzSubmissionStatus.initial,
    this.name = const Groupname.pure(),
    this.description = const GroupDescription.pure(),
    this.avatar = const GroupAvatar.pure(),
    this.participants = const GroupParticipants.pure(),
    this.addParticipants = const GroupParticipants.pure(),
    this.removeParticipants = const GroupParticipants.pure(),
    this.isValid = false,
    this.errorMessage,
    this.informationMessage,
  });

  final ConversationModel conversation;
  final FormzSubmissionStatus status;
  final Groupname name;
  final GroupDescription description;
  final GroupAvatar avatar;
  final GroupParticipants participants;
  final GroupParticipants addParticipants;
  final GroupParticipants removeParticipants;
  final bool isValid;
  final String? errorMessage;
  final String? informationMessage;

  GroupInfoState copyWith({
    FormzSubmissionStatus? status,
    Groupname? name,
    GroupDescription? description,
    GroupAvatar? avatar,
    GroupParticipants? participants,
    GroupParticipants? addParticipants,
    GroupParticipants? removeParticipants,
    bool? isValid,
    String? errorMessage,
    String? informationMessage,
  }) {
    return GroupInfoState(
      conversation: conversation,
      status: status ?? this.status,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      participants: participants ?? this.participants,
      addParticipants: addParticipants ?? this.addParticipants,
      removeParticipants: removeParticipants ?? this.removeParticipants,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      informationMessage: informationMessage ?? this.informationMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        description,
        avatar,
        participants,
        addParticipants,
        removeParticipants
      ];
}
