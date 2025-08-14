import 'package:formz/formz.dart';

import '../../../shared/utils/api_utils.dart';
import 'chat_message.dart';

enum SelectedChatsValidationError {
  empty,
  long,
}

class SelectedMessages
    extends FormzInput<Set<ChatMessage>, SelectedChatsValidationError> {
  const SelectedMessages.pure() : super.pure(const {});

  const SelectedMessages.dirty([super.value = const {}]) : super.dirty();

  @override
  SelectedChatsValidationError? validator(Set<ChatMessage> value) {
    if (value.isEmpty) return SelectedChatsValidationError.empty;
    if (value.length > maxChatsForwardTo) {
      return SelectedChatsValidationError.long;
    }
    return null;
  }
}
