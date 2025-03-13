import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';

import '../../../api/api.dart';
import '../../../db/models/models.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../models/models.dart';

part 'group_info_event.dart';

part 'group_info_state.dart';

class GroupInfoBloc extends Bloc<GroupInfoEvent, GroupInfoState> {
  GroupInfoBloc(this._conversationRepository, this._userRepository,
      {required ConversationModel conversation})
      : super(GroupInfoState(conversation: conversation)) {
    on<GroupParticipantsReceived>(_onGroupInfoParticipantsReceived);
    on<GroupAvatarPicked>(_onGroupAvatarPicked);
    on<GroupNameChanged>(_onGroupNameChanged);
    on<GroupDescriptionChanged>(_onGroupDescriptionChanged);
    on<GroupAddParticipantsAdded>(_onGroupAddParticipantsAdded);
    on<GroupAddParticipantsRemoved>(_onGroupAddParticipantsRemoved);
    on<GroupRemoveParticipants>(_onGroupRemoveParticipants);
    on<GroupInfoResetChanges>(_onResetChanges);
    on<GroupInfoSubmitted>(_onSubmitted);

    add(GroupParticipantsReceived(conversation.participants.toList()));

    _conversationRepository
        .getParticipants([state.conversation.id]).then((users) {
      add(GroupParticipantsReceived(users.$2));
    });
  }

  final ConversationRepository _conversationRepository;
  final UserRepository _userRepository;

  Future<void> _onGroupInfoParticipantsReceived(
    GroupParticipantsReceived event,
    Emitter<GroupInfoState> emit,
  ) async {
    emit(
      state.copyWith(
          status: FormzSubmissionStatus.initial,
          name: Groupname.pure(state.conversation.name),
          description:
              GroupDescription.pure(state.conversation.description ?? ''),
          avatar: GroupAvatar.pure(state.conversation.avatar?.imageUrl),
          currentUser: await _userRepository.getCurrentUser(),
          participants: GroupParticipants.pure(event.participants.toSet())),
    );
  }

  Future<void> _onGroupAvatarPicked(
    GroupAvatarPicked event,
    Emitter<GroupInfoState> emit,
  ) async {
    await FilePicker.platform
        .pickFiles(type: FileType.image, compressionQuality: 0)
        .then((result) async {
      if (result != null) {
        File file = File(result.files.single.path!);
        try {
          final chat = await _conversationRepository.updateConversation(
              id: state.conversation.id, avatarUrl: file);
          emit(state.copyWith(
              status: FormzSubmissionStatus.success,
              isValid: false,
              avatar: GroupAvatar.pure(chat?.avatar?.imageUrl ?? ''),
              informationMessage: 'Chat was successfully updated'));
        } catch (e) {
          emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              isValid: false,
              errorMessage: 'Chat wasn\'t updated: $e'));
        }
      } else {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: "image file is empty or not valid",
          ),
        );
      }
    });
  }

  void _onGroupNameChanged(
    GroupNameChanged event,
    Emitter<GroupInfoState> emit,
  ) {
    final name = Groupname.dirty(event.name);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        name: name,
        isValid: Formz.validate([name]),
      ),
    );
  }

  void _onGroupDescriptionChanged(
    GroupDescriptionChanged event,
    Emitter<GroupInfoState> emit,
  ) {
    final description = GroupDescription.dirty(event.description);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        description: description,
        isValid: Formz.validate([description]),
      ),
    );
  }

  void _onGroupAddParticipantsAdded(
    GroupAddParticipantsAdded event,
    Emitter<GroupInfoState> emit,
  ) {
    var users = Set.of(state.addParticipants.value);
    users.add(event.participant);
    final participants =
        GroupParticipants.dirty(users, state.participants.value.length);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        addParticipants: participants,
        isValid: Formz.validate([participants]),
      ),
    );
  }

  void _onGroupAddParticipantsRemoved(
    GroupAddParticipantsRemoved event,
    Emitter<GroupInfoState> emit,
  ) {
    final user = event.participant;
    final users = Set.of(state.addParticipants.value);
    users.remove(user);
    final participants =
        GroupParticipants.dirty(users, state.participants.value.length);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        addParticipants: participants,
        isValid: Formz.validate([participants]),
      ),
    );
  }

  void _onGroupRemoveParticipants(
    GroupRemoveParticipants event,
    Emitter<GroupInfoState> emit,
  ) {
    final user = event.participant;
    final users = Set.of(state.removeParticipants.value);
    users.add(user);
    final participants = GroupParticipants.dirty(users);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        removeParticipants: participants,
        isValid: Formz.validate([participants]),
      ),
    );
  }

  Future<void> _onResetChanges(
    GroupInfoResetChanges event,
    Emitter<GroupInfoState> emit,
  ) async {
    var chat = await _conversationRepository
        .getConversationById(state.conversation.id);
    var participants =
        await _conversationRepository.getParticipants([state.conversation.id]);
    emit(
      state.copyWith(
          status: FormzSubmissionStatus.canceled,
          isValid: false,
          name: Groupname.pure(chat?.name ?? ''),
          description: GroupDescription.pure(chat?.description ?? ''),
          participants: GroupParticipants.pure(participants.$2.toSet()),
          addParticipants: const GroupParticipants.pure(),
          removeParticipants: const GroupParticipants.pure()),
    );
  }

  Future<void> _onSubmitted(
    GroupInfoSubmitted event,
    Emitter<GroupInfoState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        var chat = await _conversationRepository.updateConversation(
            id: state.conversation.id,
            name: state.name.isValid && !state.name.isPure
                ? state.name.value
                : null,
            description: state.description.isValid && !state.description.isPure
                ? state.description.value
                : null,
            addParticipants:
                state.addParticipants.isValid && !state.addParticipants.isPure
                    ? state.addParticipants.value
                    : null,
            removeParticipants: state.removeParticipants.isValid &&
                    !state.removeParticipants.isPure
                ? state.removeParticipants.value
                : null);
        var participants =
            await _conversationRepository.getParticipants([chat?.id ?? '']);
        emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            isValid: false,
            name: Groupname.pure(chat?.name ?? ''),
            description: GroupDescription.pure(chat?.description ?? ''),
            participants: GroupParticipants.pure(Set.of(participants.$2)),
            addParticipants: const GroupParticipants.pure(),
            removeParticipants: const GroupParticipants.pure(),
            informationMessage: 'Chat was successfully updated'));
      } on ResponseException catch (e) {
        var chat = await _conversationRepository
            .getConversationById(state.conversation.id);
        var participants =
            await _conversationRepository.getParticipants([chat!.id]);
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            isValid: false,
            name: Groupname.pure(chat.name),
            description: GroupDescription.pure(chat.description ?? ''),
            participants: GroupParticipants.pure(participants.$2.toSet()),
            addParticipants: const GroupParticipants.pure(),
            removeParticipants: const GroupParticipants.pure(),
            errorMessage: 'Chat wasn\'t updated: ${e.message}'));
      }
    }
  }
}
