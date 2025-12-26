import 'package:formz/formz.dart';

import '../../../db/models/user_model.dart';
import '../../../shared/utils/api_utils.dart';

enum ParticipantsValidationError {
  empty,
  long,
}

class Participants
    extends FormzInput<Set<UserModel>, ParticipantsValidationError> {
  const Participants.pure() : super.pure(const {});

  const Participants.dirty([super.value = const {}]) : super.dirty();

  @override
  ParticipantsValidationError? validator(Set<UserModel> value) {
    if (value.isEmpty) return ParticipantsValidationError.empty;
    if (value.length > maxParticipantsCount) {
      return ParticipantsValidationError.long;
    }
    return null;
  }
}
