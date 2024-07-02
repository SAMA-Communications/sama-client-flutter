import 'package:formz/formz.dart';

enum PasswordValidationError { empty, short, unavailableSymbols }

const int passwordMinLength = 3;

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;

    if (value.length < passwordMinLength) return PasswordValidationError.short;
    return null;
  }
}
