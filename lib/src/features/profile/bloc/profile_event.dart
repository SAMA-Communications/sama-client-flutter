part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileUserReceived extends ProfileEvent {
  const ProfileUserReceived(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}

final class ProfileAvatarPicked extends ProfileEvent {}

final class ProfileUserFirstnameChanged extends ProfileEvent {
  const ProfileUserFirstnameChanged(this.firstname);

  final String firstname;

  @override
  List<Object> get props => [firstname];
}

final class ProfileUserLastnameChanged extends ProfileEvent {
  const ProfileUserLastnameChanged(this.lastname);

  final String lastname;

  @override
  List<Object> get props => [lastname];
}

final class ProfilePhoneChanged extends ProfileEvent {
  const ProfilePhoneChanged(this.phone);

  final String phone;

  @override
  List<Object> get props => [phone];
}

final class ProfileEmailChanged extends ProfileEvent {
  const ProfileEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class ProfilePasswordChanged extends ProfileEvent {
  const ProfilePasswordChanged(this.currentPassword, this.newPassword);

  final String currentPassword;
  final String newPassword;

  @override
  List<Object> get props => [currentPassword, newPassword];
}

final class ProfileResetChanges extends ProfileEvent {}

final class ProfileSubmitted extends ProfileEvent {}
