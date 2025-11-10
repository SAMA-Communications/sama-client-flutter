import 'package:formz/formz.dart';

enum EmailValidationError { empty, incorrect }

const int userEmailMinLength = 3;

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure([super.value = '']) : super.pure();

  const Email.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;

    if (value.trim().length < userEmailMinLength ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value)) return EmailValidationError.incorrect;
    return null;
  }
}
