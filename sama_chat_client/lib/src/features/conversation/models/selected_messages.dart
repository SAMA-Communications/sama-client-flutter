import 'package:formz/formz.dart';
import 'package:sama_sdk/api/settings.dart';

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
    if (value.length > maxChatsToSelect) {
      return SelectedChatsValidationError.long;
    }
    return null;
  }
}
