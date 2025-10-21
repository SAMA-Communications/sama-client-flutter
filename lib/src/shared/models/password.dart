import 'package:formz/formz.dart';

enum PasswordValidationError { empty, short, long, unavailableSymbols }

const int passwordMinLength = 3;
const int passwordMaxLength = 40;

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;

    if (value.trim().length < passwordMinLength) {
      return PasswordValidationError.short;
    }
    if (value.trim().length > passwordMaxLength) {
      return PasswordValidationError.long;
    }
    return null;
  }
}
