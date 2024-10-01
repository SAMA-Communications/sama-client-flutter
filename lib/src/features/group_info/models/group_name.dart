import 'package:formz/formz.dart';

enum GroupnameValidationError { empty, short }

const int groupNameMinLength = 1;

class Groupname extends FormzInput<String, GroupnameValidationError> {
  const Groupname.pure([super.value = '']) : super.pure();

  const Groupname.dirty([super.value = '']) : super.dirty();

  @override
  GroupnameValidationError? validator(String value) {
    if (value.isEmpty) return GroupnameValidationError.empty;

    if (value.trim().length < groupNameMinLength) {
      return GroupnameValidationError.short;
    }
    return null;
  }
}
