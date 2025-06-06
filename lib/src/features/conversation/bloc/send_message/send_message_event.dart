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

final class TextMessageChanged extends SendMessageEvent {
  final String text;

  const TextMessageChanged(this.text);
}

final class TextMessageClear extends SendMessageEvent {
  const TextMessageClear();
}

// TODO RP maybe later move to separate bloc along with editMessage and deleteMessages
final class SendStatusReadMessages extends SendMessageEvent {
  const SendStatusReadMessages();
}

final class SendTypingChanged extends SendMessageEvent {
  const SendTypingChanged();
}
