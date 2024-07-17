part of 'conversation_bloc.dart';

enum ConversationStatus { initial, success, failure }

final class ConversationState extends Equatable {
  const ConversationState({
    this.status = ConversationStatus.initial,
    this.messages = const <ChatMessage>[],
    this.participants = const <User>[],
    this.hasReachedMax = false,
  });

  final ConversationStatus status;
  final List<ChatMessage> messages;
  final List<User> participants;
  final bool hasReachedMax;

  ConversationState copyWith({
    ConversationStatus? status,
    List<ChatMessage>? messages,
    List<User>? participants,
    bool? hasReachedMax,
  }) {
    return ConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, messages: ${messages.length}, participants: ${participants.length} }''';
  }

  @override
  List<Object> get props => [status, messages, hasReachedMax, participants];
}
