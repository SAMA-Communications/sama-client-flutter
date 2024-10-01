import 'package:formz/formz.dart';

import '../../../api/api.dart';

enum GroupParticipantsValidationError { empty, long }

const int maxParticipantsCount = 50;

class GroupParticipants
    extends FormzInput<Set<User>, GroupParticipantsValidationError> {
  const GroupParticipants.pure([super.value = const {}]) : super.pure();

  const GroupParticipants.dirty([super.value = const {}]) : super.dirty();

  @override
  GroupParticipantsValidationError? validator(Set<User> value) {
    if (value.isEmpty) return GroupParticipantsValidationError.empty;
    if (value.length > maxParticipantsCount) {
      GroupParticipantsValidationError.long;
    }
    return null;
  }
}
