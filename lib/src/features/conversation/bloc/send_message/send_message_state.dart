part of 'send_message_bloc.dart';

enum SendMessageStatus { initial, processing, success, failure }

final class SendMessageState extends Equatable {
  const SendMessageState({
    this.status = SendMessageStatus.initial,
    this.isTextEmpty = true,
    this.text = '',
    this.errorMessage,
    this.draftMessage,
    this.replyMessage,
    this.editMessage,
  });

  final SendMessageStatus status;
  final bool isTextEmpty;
  final String text;
  final String? errorMessage;
  final MessageModel? draftMessage;
  final MessageModel? replyMessage;
  final MessageModel? editMessage;

  SendMessageState copyWith({
    SendMessageStatus? status,
    bool? isTextEmpty,
    String? text,
    String? errorMessage,
    MessageModel? Function()? draftMessage,
    MessageModel? Function()? replyMessage,
    MessageModel? Function()? editMessage,
  }) {
    return SendMessageState(
      status: status ?? this.status,
      isTextEmpty: isTextEmpty ?? this.isTextEmpty,
      text: text ?? this.text,
      errorMessage: errorMessage ?? this.errorMessage,
      draftMessage: draftMessage != null ? draftMessage() : this.draftMessage,
      replyMessage: replyMessage != null ? replyMessage() : this.replyMessage,
      editMessage: editMessage != null ? editMessage() : this.editMessage,
    );
  }

  @override
  String toString() {
    return '''SendMessageState { status: $status, isTextEmpty: $isTextEmpty, text: $text, errorMessage: $errorMessage }''';
  }

  @override
  List<Object?> get props => [
        status,
        isTextEmpty,
        text,
        errorMessage,
        draftMessage,
        replyMessage,
        editMessage
      ];
}
