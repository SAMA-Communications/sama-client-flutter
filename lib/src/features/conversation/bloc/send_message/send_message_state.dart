part of 'send_message_bloc.dart';

enum SendMessageStatus { initial, success, failure }

final class SendMessageState extends Equatable {
  const SendMessageState({
    this.status = SendMessageStatus.initial,
    this.isTextEmpty = true,
    this.text = '',
  });

  final SendMessageStatus status;
  final bool isTextEmpty;
  final String text;

  SendMessageState copyWith({
    SendMessageStatus? status,
    bool? isTextEmpty,
    String? text,
  }) {
    return SendMessageState(
      status: status ?? this.status,
      isTextEmpty: isTextEmpty ?? this.isTextEmpty,
      text: text ?? this.text,
    );
  }

  @override
  String toString() {
    return '''SendMessageState { status: $status, isTextEmpty: $isTextEmpty, text: $text }''';
  }

  @override
  List<Object> get props => [status, isTextEmpty, text];
}
