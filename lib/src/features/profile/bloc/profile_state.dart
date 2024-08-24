part of 'profile_bloc.dart';

final class ProfileState extends Equatable {
  const ProfileState({
    this.status = FormzSubmissionStatus.initial,
    this.userLogin = '',
    this.userAvatar = const UserAvatar.pure(),
    this.userFirstname = const UserFirstname.pure(),
    this.userLastname = const UserLastname.pure(),
    this.userPhone = const UserPhone.pure(),
    this.userEmail = const UserEmail.pure(),
    this.isValid = false,
    this.errorMessage,
    this.informationMessage,
  });

  final FormzSubmissionStatus status;
  final String userLogin;
  final UserAvatar userAvatar;
  final UserFirstname userFirstname;
  final UserLastname userLastname;
  final UserPhone userPhone;
  final UserEmail userEmail;
  final bool isValid;
  final String? errorMessage;
  final String? informationMessage;

  ProfileState copyWith({
    FormzSubmissionStatus? status,
    String? userLogin,
    UserAvatar? userAvatar,
    UserFirstname? userFirstname,
    UserLastname? userLastname,
    UserPhone? userPhone,
    UserEmail? userEmail,
    bool? isValid,
    String? errorMessage,
    String? informationMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userLogin: userLogin ?? this.userLogin,
      userAvatar: userAvatar ?? this.userAvatar,
      userFirstname: userFirstname ?? this.userFirstname,
      userLastname: userLastname ?? this.userLastname,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      informationMessage: informationMessage ?? this.informationMessage,
    );
  }

  @override
  List<Object> get props =>
      [status, userAvatar, userFirstname, userLastname, userPhone, userEmail];
}
