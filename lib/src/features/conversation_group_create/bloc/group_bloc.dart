import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';

import '../../../api/api.dart';
import '../models/avatar.dart';
import '../models/groupname.dart';
import '../models/participants.dart';

part 'group_event.dart';

part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc() : super(const GroupState()) {
    on<GroupnameChanged>(_onGroupnameChanged);
    on<GroupAvatarPicked>(_onGroupAvatarPicked);
    on<GroupParticipantsAdded>(_onGroupParticipantsAdded);
    on<GroupParticipantsRemoved>(_onGroupParticipantsRemoved);
    on<GroupSubmitted>(_onGroupSubmitted);
  }

  void _onGroupnameChanged(
    GroupnameChanged event,
    Emitter<GroupState> emit,
  ) {
    final groupname = Groupname.dirty(event.groupname);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        groupname: groupname,
        isValid: Formz.validate([state.participants, groupname]),
      ),
    );
  }

  Future<void> _onGroupAvatarPicked(
    GroupAvatarPicked event,
    Emitter<GroupState> emit,
  ) async {
    await FilePicker.platform
        .pickFiles(type: FileType.image, compressionQuality: 0)
        .then((result) {
      if (result != null) {
        File file = File(result.files.single.path!);
        final avatarUrl = GroupAvatar.dirty(file);
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.initial,
            avatar: avatarUrl,
            isValid: Formz.validate(
                [state.participants, state.groupname, avatarUrl]),
          ),
        );
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

  void _onGroupParticipantsAdded(
    GroupParticipantsAdded event,
    Emitter<GroupState> emit,
  ) {
    var users = Set.of(state.participants.value);
    users.add(event.user);
    final participants = Participants.dirty(users);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        participants: participants,
        isValid: Formz.validate([state.groupname, participants]),
      ),
    );
  }

  void _onGroupParticipantsRemoved(
    GroupParticipantsRemoved event,
    Emitter<GroupState> emit,
  ) {
    final user = event.user;
    final users = Set.of(state.participants.value);
    users.remove(user);
    final participants = Participants.dirty(users);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        participants: participants,
        isValid: Formz.validate([state.groupname, participants]),
      ),
    );
  }

  Future<void> _onGroupSubmitted(
    GroupSubmitted event,
    Emitter<GroupState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (_) {}
    } else {
      emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Not enough data'));
    }
  }
}
