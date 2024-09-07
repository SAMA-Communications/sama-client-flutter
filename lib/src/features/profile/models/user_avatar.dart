import 'package:formz/formz.dart';

enum UserAvatarValidationError { empty }

class UserAvatar extends FormzInput<String?, UserAvatarValidationError> {
  const UserAvatar.pure([super.value = '']) : super.pure();

  const UserAvatar.dirty([super.value]) : super.dirty();

  @override
  UserAvatarValidationError? validator(String? value) {
    if (value == null) {
      return UserAvatarValidationError.empty;
    }
    return null;
  }
}
