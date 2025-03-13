part of 'conversation_bloc.dart';

enum ConversationStatus { initial, success, failure, delete }

final class ConversationState extends Equatable {
  const ConversationState({
    required this.conversation,
    this.status = ConversationStatus.initial,
    this.messages = const <ChatMessage>[],
    this.participants = const <UserModel>{},
    this.hasReachedMax = false,
    this.initial = false,
  });

  final ConversationModel conversation;
  final ConversationStatus status;
  final List<ChatMessage> messages;
  final Set<UserModel> participants;
  final bool hasReachedMax;
  final bool initial;

  ConversationState copyWith({
    ConversationModel? conversation,
    ConversationStatus? status,
    List<ChatMessage>? messages,
    Set<UserModel>? participants,
    bool? hasReachedMax,
    bool? initial,
  }) {
    return ConversationState(
      conversation: conversation ?? this.conversation,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initial: initial ?? this.initial,
    );
  }

  @override
  String toString() {
    return 'ConversationState { status: $status, hasReachedMax: $hasReachedMax, initial: $initial, messages: ${messages.length}, participants: ${participants.length} }';
  }

  @override
  List<Object> get props =>
      [conversation, status, messages, hasReachedMax, initial, participants];
}
