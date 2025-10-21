import 'package:formz/formz.dart';

import '../../../db/models/user_model.dart';
import '../../../shared/utils/api_utils.dart';

enum GroupParticipantsValidationError { empty, long }

class GroupParticipants
    extends FormzInput<Set<UserModel>, GroupParticipantsValidationError> {
  const GroupParticipants.pure(
      [super.value = const {}, this.participantsCount = 0])
      : super.pure();

  const GroupParticipants.dirty(
      [super.value = const {}, this.participantsCount = 0])
      : super.dirty();

  final int participantsCount;

  @override
  GroupParticipantsValidationError? validator(Set<UserModel> value) {
    if (value.isEmpty) return GroupParticipantsValidationError.empty;
    if (value.length > maxParticipantsCount - participantsCount) {
      return GroupParticipantsValidationError.long;
    }
    return null;
  }
}
