import 'package:formz/formz.dart';

enum GroupAvatarValidationError { empty }

class GroupAvatar extends FormzInput<String?, GroupAvatarValidationError> {
  const GroupAvatar.pure([super.value = '']) : super.pure();

  const GroupAvatar.dirty([super.value]) : super.dirty();

  @override
  GroupAvatarValidationError? validator(String? value) {
    if (value == null) {
      return GroupAvatarValidationError.empty;
    }
    return null;
  }
}
