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
