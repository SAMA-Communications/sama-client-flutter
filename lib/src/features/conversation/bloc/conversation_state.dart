part of 'conversation_bloc.dart';

enum ConversationStatus { initial, success, failure }

final class ConversationState extends Equatable {
  const ConversationState({
    required this.conversation,
    this.status = ConversationStatus.initial,
    this.messages = const <ChatMessage>[],
    this.participants = const <User>{},
    this.hasReachedMax = false,
  });

  final ConversationModel conversation;
  final ConversationStatus status;
  final List<ChatMessage> messages;
  final Set<User> participants;
  final bool hasReachedMax;

  ConversationState copyWith({
    ConversationModel? conversation,
    ConversationStatus? status,
    List<ChatMessage>? messages,
    Set<User>? participants,
    bool? hasReachedMax,
  }) {
    return ConversationState(
      conversation: conversation ?? this.conversation,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return 'ConversationState { status: $status, hasReachedMax: $hasReachedMax, messages: ${messages.length}, participants: ${participants.length} }';
  }

  @override
  List<Object> get props =>
      [conversation, status, messages, hasReachedMax, participants];
}
