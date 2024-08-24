import 'package:formz/formz.dart';

enum UserFirstnameValidationError { empty }

class UserFirstname extends FormzInput<String, UserFirstnameValidationError> {
  const UserFirstname.pure([super.value = '']) : super.pure();

  const UserFirstname.dirty([super.value = '']) : super.dirty();

  @override
  UserFirstnameValidationError? validator(String value) {
    if (value.isEmpty) return UserFirstnameValidationError.empty;
    return null;
  }
}
