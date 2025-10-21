import 'dart:io';

import 'package:formz/formz.dart';

enum GroupAvatarValidationError { empty }

class GroupAvatar extends FormzInput<File?, GroupAvatarValidationError> {
  const GroupAvatar.pure() : super.pure(null);

  const GroupAvatar.dirty([super.value]) : super.dirty();

  @override
  GroupAvatarValidationError? validator(File? value) {
    if (value == null || !value.existsSync()) {
      return GroupAvatarValidationError.empty;
    }
    return null;
  }
}
