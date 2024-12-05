import 'package:formz/formz.dart';

import '../../../api/api.dart';
import '../../../shared/utils/api_utils.dart';

enum ParticipantsValidationError {
  empty,
  long,
}

class Participants extends FormzInput<Set<User>, ParticipantsValidationError> {
  const Participants.pure() : super.pure(const {});

  const Participants.dirty([super.value = const {}]) : super.dirty();

  @override
  ParticipantsValidationError? validator(Set<User> value) {
    if (value.isEmpty) return ParticipantsValidationError.empty;
    if (value.length > maxParticipantsCount) ParticipantsValidationError.long;
    return null;
  }
}
