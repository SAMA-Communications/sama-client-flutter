part of 'send_message_bloc.dart';

enum SendMessageStatus { initial, processing, success, failure }

final class SendMessageState extends Equatable {
  const SendMessageState({
    this.status = SendMessageStatus.initial,
    this.isTextEmpty = true,
    this.text = '',
    this.errorMessage,
  });

  final SendMessageStatus status;
  final bool isTextEmpty;
  final String text;
  final String? errorMessage;

  SendMessageState copyWith({
    SendMessageStatus? status,
    bool? isTextEmpty,
    String? text,
    String? errorMessage
  }) {
    return SendMessageState(
      status: status ?? this.status,
      isTextEmpty: isTextEmpty ?? this.isTextEmpty,
      text: text ?? this.text,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return '''SendMessageState { status: $status, isTextEmpty: $isTextEmpty, text: $text, errorMessage: $errorMessage }''';
  }

  @override
  List<Object?> get props => [status, isTextEmpty, text, errorMessage];
}
