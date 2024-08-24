import 'dart:io';

import 'package:formz/formz.dart';

enum UserAvatarValidationError { empty }

const int loginMinLength = 1;

class UserAvatar extends FormzInput<File?, UserAvatarValidationError> {
  const UserAvatar.pure() : super.pure(null);

  const UserAvatar.dirty([super.value]) : super.dirty();

  @override
  UserAvatarValidationError? validator(File? value) {
    if (value == null || !value.existsSync()) {
      return UserAvatarValidationError.empty;
    }
    return null;
  }
}
