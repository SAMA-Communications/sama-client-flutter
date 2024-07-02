import 'package:formz/formz.dart';

enum UsernameValidationError { empty, short }

const int loginMinLength = 3;

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');

  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) return UsernameValidationError.empty;

    if (value.length < loginMinLength) return UsernameValidationError.short;
    return null;
  }
}
