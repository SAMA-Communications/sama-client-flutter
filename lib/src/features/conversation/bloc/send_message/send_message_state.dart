part of 'send_message_bloc.dart';

enum SendMessageStatus { initial, processing, success, failure }

final class SendMessageState extends Equatable {
  const SendMessageState({
    this.status = SendMessageStatus.initial,
    this.isTextEmpty = true,
    this.errorMessage,
  });

  final SendMessageStatus status;
  final bool isTextEmpty;
  final String? errorMessage;

  SendMessageState copyWith(
      {SendMessageStatus? status, bool? isTextEmpty, String? errorMessage}) {
    return SendMessageState(
      status: status ?? this.status,
      isTextEmpty: isTextEmpty ?? this.isTextEmpty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return '''SendMessageState { status: $status, isTextEmpty: $isTextEmpty , errorMessage: $errorMessage }''';
  }

  @override
  List<Object?> get props => [status, isTextEmpty, errorMessage];
}
