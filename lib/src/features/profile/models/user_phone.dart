import 'package:formz/formz.dart';

enum UserPhoneValidationError { empty, outOfRange }

const int userPhoneMinLength = 3;
const int userPhoneMaxLength = 15;

class UserPhone extends FormzInput<String, UserPhoneValidationError> {
  const UserPhone.pure([super.value = '']) : super.pure();

  const UserPhone.dirty([super.value = '']) : super.dirty();

  @override
  UserPhoneValidationError? validator(String value) {
    if (value.isEmpty) return UserPhoneValidationError.empty;

    if (value.trim().length < userPhoneMinLength ||
        value.trim().length > userPhoneMaxLength) {
      return UserPhoneValidationError.outOfRange;
    }
    return null;
  }
}
