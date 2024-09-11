import 'package:formz/formz.dart';

enum UserEmailValidationError { empty, incorrect }

const int userEmailMinLength = 3;

class UserEmail extends FormzInput<String, UserEmailValidationError> {
  const UserEmail.pure([super.value = '']) : super.pure();

  const UserEmail.dirty([super.value = '']) : super.dirty();

  @override
  UserEmailValidationError? validator(String value) {
    if (value.isEmpty) return UserEmailValidationError.empty;

    if (value.trim().length < userEmailMinLength ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value)) return UserEmailValidationError.incorrect;
    return null;
  }
}
