import 'package:formz/formz.dart';

enum UserLastnameValidationError { empty }

class UserLastname extends FormzInput<String, UserLastnameValidationError> {
  const UserLastname.pure([super.value = '']) : super.pure();

  const UserLastname.dirty([super.value = '']) : super.dirty();

  @override
  UserLastnameValidationError? validator(String value) {
    if (value.isEmpty) return UserLastnameValidationError.empty;

    return null;
  }
}
