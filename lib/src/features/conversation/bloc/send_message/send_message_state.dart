part of 'send_message_bloc.dart';

enum SendMessageStatus { initial, success, failure }

final class SendMessageState extends Equatable {
  const SendMessageState({
    this.status = SendMessageStatus.initial,
    this.isTextEmpty = true,
  });

  final SendMessageStatus status;
  final bool isTextEmpty;

  SendMessageState copyWith({
    SendMessageStatus? status,
    bool? isTextEmpty,
  }) {
    return SendMessageState(
      status: status ?? this.status,
      isTextEmpty: isTextEmpty ?? this.isTextEmpty,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status }''';
  }

  @override
  List<Object> get props => [status, isTextEmpty];
}
