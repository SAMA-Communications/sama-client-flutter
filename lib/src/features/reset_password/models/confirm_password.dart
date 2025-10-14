import 'package:formz/formz.dart';

enum ConfirmPasswordValidationError { empty, notMatching }

class ConfirmPassword
    extends FormzInput<String, ConfirmPasswordValidationError> {
  const ConfirmPassword.pure()
      : currentPsw = '',
        super.pure('');

  const ConfirmPassword.dirty({required this.currentPsw, String value = ''})
      : super.dirty(value);

  final String currentPsw;

  @override
  ConfirmPasswordValidationError? validator(String value) {
    if (value != currentPsw) {
      return ConfirmPasswordValidationError.notMatching;
    }
    if (currentPsw.isEmpty) return ConfirmPasswordValidationError.empty;
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ConfirmPassword &&
          runtimeType == other.runtimeType &&
          currentPsw == other.currentPsw;

  @override
  int get hashCode => super.hashCode ^ currentPsw.hashCode;
}
