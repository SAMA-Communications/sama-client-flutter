import 'package:formz/formz.dart';

enum UserLastnameValidationError { empty, outOfRange }

const int userLastnameMaxLength = 20;

class UserLastname extends FormzInput<String, UserLastnameValidationError> {
  const UserLastname.pure([super.value = '']) : super.pure();

  const UserLastname.dirty([super.value = '']) : super.dirty();

  @override
  UserLastnameValidationError? validator(String value) {
    if (value.isEmpty) return UserLastnameValidationError.empty;

    if (value.trim().length > userLastnameMaxLength) {
      return UserLastnameValidationError.outOfRange;
    }
    return null;
  }
}
