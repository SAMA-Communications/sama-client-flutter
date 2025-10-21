import 'package:formz/formz.dart';

enum UserPasswordValidationError { empty, outOfRange }

const int userPasswordMinLength = 3;
const int userPasswordMaxLength = 40;

class UserPassword extends FormzInput<String, UserPasswordValidationError> {
  const UserPassword.pure()
      : currentPsw = '',
        super.pure('');

  const UserPassword.dirty({required this.currentPsw, String value = ''})
      : super.dirty(value);

  final String currentPsw;

  @override
  UserPasswordValidationError? validator(String value) {
    if (value.trim().length < userPasswordMinLength ||
        value.trim().length > userPasswordMaxLength) {
      return UserPasswordValidationError.outOfRange;
    }
    if (currentPsw.isEmpty) return UserPasswordValidationError.empty;
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is UserPassword &&
          runtimeType == other.runtimeType &&
          currentPsw == other.currentPsw;

  @override
  int get hashCode => super.hashCode ^ currentPsw.hashCode;
}
