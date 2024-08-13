import 'package:formz/formz.dart';

enum GroupnameValidationError {
  empty,
  short,
}

const int loginMinLength = 1;

class Groupname extends FormzInput<String, GroupnameValidationError> {
  const Groupname.pure() : super.pure('');

  const Groupname.dirty([super.value = '']) : super.dirty();

  @override
  GroupnameValidationError? validator(String value) {
    if (value.isEmpty) return GroupnameValidationError.empty;

    if (value.trim().length < loginMinLength) {
      return GroupnameValidationError.short;
    }
    return null;
  }
}
