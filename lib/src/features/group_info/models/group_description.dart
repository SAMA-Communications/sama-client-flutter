import 'package:formz/formz.dart';

enum GroupDescriptionValidationError { empty, short }

const int groupDescriptionMinLength = 1;

class GroupDescription
    extends FormzInput<String, GroupDescriptionValidationError> {
  const GroupDescription.pure([super.value = '']) : super.pure();

  const GroupDescription.dirty([super.value = '']) : super.dirty();

  @override
  GroupDescriptionValidationError? validator(String value) {
    if (value.isEmpty) return GroupDescriptionValidationError.empty;

    if (value.trim().length < groupDescriptionMinLength) {
      return GroupDescriptionValidationError.short;
    }
    return null;
  }
}
