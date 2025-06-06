part of 'conversation_bloc.dart';

enum ConversationStatus { initial, success, failure, delete }

class TypingMessageStatus {
  final TypingState typingState;
  final UserModel? user;

  TypingMessageStatus(this.typingState, this.user);
}

final class ConversationState extends Equatable {
  const ConversationState({
    required this.conversation,
    this.status = ConversationStatus.initial,
    this.messages = const <ChatMessage>[],
    this.participants = const <UserModel>{},
    this.hasReachedMax = false,
    this.initial = false,
    this.draftMessage,
    this.typingStatus,
  });

  final ConversationModel conversation;
  final ConversationStatus status;
  final List<ChatMessage> messages;
  final Set<UserModel> participants;
  final bool hasReachedMax;
  final bool initial;
  final MessageModel? draftMessage;
  final TypingMessageStatus? typingStatus;

  ConversationState copyWith({
    ConversationModel? conversation,
    ConversationStatus? status,
    List<ChatMessage>? messages,
    Set<UserModel>? participants,
    bool? hasReachedMax,
    bool? initial,
    MessageModel? Function()? draftMessage,
    TypingMessageStatus? typingStatus,
  }) {
    return ConversationState(
      conversation: conversation ?? this.conversation,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initial: initial ?? this.initial,
      draftMessage: draftMessage != null ? draftMessage() : this.draftMessage,
      typingStatus: typingStatus,
    );
  }

  @override
  String toString() {
    return 'ConversationState { status: $status, hasReachedMax: $hasReachedMax, initial: $initial, messages: ${messages.length}, participants: ${participants.length}, draftMessage: $draftMessage';
  }

  @override
  List<Object?> get props => [
        conversation,
        status,
        messages,
        hasReachedMax,
        initial,
        participants,
        draftMessage,
        typingStatus
      ];
}
