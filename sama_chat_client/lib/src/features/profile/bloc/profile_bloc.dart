import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';

import '../../../api/api.dart';
import '../../../db/models/models.dart';
import '../../../repository/user/user_repository.dart';
import '../models/models.dart';
import '../models/user_avatar.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const ProfileState()) {
    on<ProfileUserReceived>(_onUserReceived);
    on<ProfileAvatarPicked>(_onUserAvatarPicked);
    on<ProfileUserFirstnameChanged>(_onUserFirstnameChanged);
    on<ProfileUserLastnameChanged>(_onUserLastnameChanged);
    on<ProfilePhoneChanged>(_onPhoneChanged);
    on<ProfileEmailChanged>(_onEmailChanged);
    on<ProfilePasswordChanged>(_onPasswordChanged);
    on<ProfileResetChanges>(_onResetChanges);
    on<ProfileSubmitted>(_onSubmitted);

    _userRepository.getCurrentUser().then((user) {
      add(ProfileUserReceived(user));
    });
  }

  final UserRepository _userRepository;

  void _onUserReceived(
    ProfileUserReceived event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
          status: FormzSubmissionStatus.initial,
          userLogin: event.user?.login,
          userAvatar: UserAvatar.pure(event.user?.avatar?.imageUrl ?? ''),
          userFirstname: UserFirstname.pure(event.user?.firstName ?? ''),
          userLastname: UserLastname.pure(event.user?.lastName ?? ''),
          userPhone: UserPhone.pure(event.user?.phone ?? ''),
          userEmail: UserEmail.pure(event.user?.email ?? '')),
    );
  }

  Future<void> _onUserAvatarPicked(
    ProfileAvatarPicked event,
    Emitter<ProfileState> emit,
  ) async {
    await FilePicker.platform
        .pickFiles(type: FileType.image, compressionQuality: 0)
        .then((result) async {
      if (result != null) {
        File file = File(result.files.single.path!);
        try {
          final user = await _userRepository.updateAvatar(file);
          emit(state.copyWith(
              status: FormzSubmissionStatus.success,
              isValid: false,
              userAvatar: UserAvatar.pure(user.avatar?.imageUrl ?? ''),
              informationMessage: 'User was successfully updated'));
        } catch (e) {
          emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              isValid: false,
              userAvatar: const UserAvatar.pure(),
              errorMessage: 'User wasn\'t updated: $e'));
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

  void _onUserFirstnameChanged(
    ProfileUserFirstnameChanged event,
    Emitter<ProfileState> emit,
  ) {
    final firstname = UserFirstname.dirty(event.firstname);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        userFirstname: firstname,
        isValid: Formz.validate([firstname]),
      ),
    );
  }

  void _onUserLastnameChanged(
    ProfileUserLastnameChanged event,
    Emitter<ProfileState> emit,
  ) {
    final lastname = UserLastname.dirty(event.lastname);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        userLastname: lastname,
        isValid: Formz.validate([lastname]),
      ),
    );
  }

  void _onPhoneChanged(
    ProfilePhoneChanged event,
    Emitter<ProfileState> emit,
  ) {
    final phone = UserPhone.dirty(event.phone);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        userPhone: phone,
        isValid: Formz.validate([phone]),
      ),
    );
  }

  void _onEmailChanged(
    ProfileEmailChanged event,
    Emitter<ProfileState> emit,
  ) {
    final email = UserEmail.dirty(event.email);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        userEmail: email,
        isValid: Formz.validate([email]),
      ),
    );
  }

  void _onPasswordChanged(
    ProfilePasswordChanged event,
    Emitter<ProfileState> emit,
  ) {
    final password = UserPassword.dirty(
        currentPsw: event.currentPassword, value: event.newPassword);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        userPassword: password,
        isValid: Formz.validate([password]),
      ),
    );
  }

  Future<void> _onResetChanges(
    ProfileResetChanges event,
    Emitter<ProfileState> emit,
  ) async {
    var user = await _userRepository.getCurrentUser();
    emit(
      state.copyWith(
          status: FormzSubmissionStatus.canceled,
          isValid: false,
          userFirstname: UserFirstname.pure(user?.firstName ?? ''),
          userLastname: UserLastname.pure(user?.lastName ?? ''),
          userPhone: UserPhone.pure(user?.phone ?? ''),
          userEmail: UserEmail.pure(user?.email ?? ''),
          userPassword: const UserPassword.pure()),
    );
  }

  Future<void> _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        var user = await _userRepository.updateCurrentUser(
            currentPsw: state.userPassword.isValid
                ? state.userPassword.currentPsw
                : null,
            newPassword:
                state.userPassword.isValid && !state.userPassword.isPure
                    ? state.userPassword.value
                    : null,
            firstName:
                state.userFirstname.isValid && !state.userFirstname.isPure
                    ? state.userFirstname.value
                    : null,
            lastName: state.userLastname.isValid && !state.userLastname.isPure
                ? state.userLastname.value
                : null,
            email: state.userEmail.isValid && !state.userEmail.isPure
                ? state.userEmail.value
                : null,
            phone: state.userPhone.isValid && !state.userPhone.isPure
                ? state.userPhone.value
                : null);
        emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            isValid: false,
            userFirstname: UserFirstname.pure(user.firstName ?? ''),
            userLastname: UserLastname.pure(user.lastName ?? ''),
            userPhone: UserPhone.pure(user.phone ?? ''),
            userEmail: UserEmail.pure(user.email ?? ''),
            informationMessage: 'User was successfully updated'));
      } catch (e) {
        var user = await _userRepository.getCurrentUser();
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            isValid: false,
            userFirstname: UserFirstname.pure(user?.firstName ?? ''),
            userLastname: UserLastname.pure(user?.lastName ?? ''),
            userPhone: UserPhone.pure(user?.phone ?? ''),
            userEmail: UserEmail.pure(user?.email ?? ''),
            userPassword: const UserPassword.pure(),
            errorMessage: 'User wasn\'t updated: $e'));
      }
    }
  }
}
