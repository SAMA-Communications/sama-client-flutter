part of 'send_message_bloc.dart';

class SendMessageEvent extends Equatable {
  const SendMessageEvent();

  @override
  List<Object> get props => [];
}

final class SendTextMessage extends SendMessageEvent {
  final String message;

  const SendTextMessage(this.message);
}

final class EditTextMessage extends SendMessageEvent {
  final String message;

  const EditTextMessage(this.message);
}

final class TextMessageChanged extends SendMessageEvent {
  final String text;

  const TextMessageChanged(this.text);
}

final class TextMessageClear extends SendMessageEvent {
  const TextMessageClear();
}

final class _DraftMessageReceived extends SendMessageEvent {
  const _DraftMessageReceived();
}

final class RemoveDraftMessage extends SendMessageEvent {
  const RemoveDraftMessage();
}

final class AddReplyMessage extends SendMessageEvent {
  final ChatMessage message;

  const AddReplyMessage(this.message);
}

final class RemoveReplyMessage extends SendMessageEvent {
  const RemoveReplyMessage();
}

final class AddEditMessage extends SendMessageEvent {
  final ChatMessage message;

  const AddEditMessage(this.message);
}

final class RemoveEditMessage extends SendMessageEvent {
  const RemoveEditMessage();
}

// TODO RP maybe later move to separate bloc along with editMessage and deleteMessages
final class SendStatusReadMessages extends SendMessageEvent {
  const SendStatusReadMessages();
}

final class SendTypingChanged extends SendMessageEvent {
  const SendTypingChanged();
}
