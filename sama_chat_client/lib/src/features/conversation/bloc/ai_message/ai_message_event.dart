part of 'ai_message_bloc.dart';

sealed class AiMessageEvent extends Equatable {
  const AiMessageEvent();

  @override
  List<Object> get props => [];
}

final class GetMessagesSummary extends AiMessageEvent {
  final String filter;

  const GetMessagesSummary(this.filter);

  @override
  List<Object> get props => [filter];
}

final class GetMessageTone extends AiMessageEvent {
  final String message;
  final String filter;

  const GetMessageTone(this.message, this.filter);

  @override
  List<Object> get props => [message, filter];
}
