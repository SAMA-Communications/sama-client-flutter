part of 'ai_message_bloc.dart';

enum AiMessageStatus { initial, processing, success, failure }

final class AiMessageState extends Equatable {
  const AiMessageState({
    this.status = AiMessageStatus.initial,
    this.text = '',
    this.errorMessage,
  });

  final AiMessageStatus status;
  final String text;
  final String? errorMessage;

  AiMessageState copyWith({
    AiMessageStatus? status,
    String? text,
    String? errorMessage,
  }) {
    return AiMessageState(
        status: status ?? this.status,
        text: text ?? this.text,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  String toString() {
    return '''AiMessageState { status: $status, text: $text, errorMessage: $errorMessage }''';
  }

  @override
  List<Object?> get props => [
        status,
        text,
        errorMessage,
      ];
}
