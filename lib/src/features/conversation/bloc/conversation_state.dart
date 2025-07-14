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
    this.selectedMessages = const SelectedMessages.pure(),
    this.participants = const <UserModel>{},
    this.hasReachedMax = false,
    this.initial = false,
    this.draftMessage,
    this.replyMessage,
    this.typingStatus,
    this.replyIdToScroll = '',
    this.choose = false,
  });

  final ConversationModel conversation;
  final ConversationStatus status;
  final List<ChatMessage> messages;
  final SelectedMessages selectedMessages;
  final Set<UserModel> participants;
  final bool hasReachedMax;
  final bool initial;
  final bool choose;
  final MessageModel? draftMessage;
  final ChatMessage? replyMessage;
  final TypingMessageStatus? typingStatus;
  final String replyIdToScroll;

  ConversationState copyWith({
    ConversationModel? conversation,
    ConversationStatus? status,
    List<ChatMessage>? messages,
    SelectedMessages? selectedMessages,
    Set<UserModel>? participants,
    bool? hasReachedMax,
    bool? initial,
    bool? choose,
    String? replyIdToScroll,
    MessageModel? Function()? draftMessage,
    ChatMessage? Function()? replyMessage,
    TypingMessageStatus? typingStatus,
  }) {
    return ConversationState(
      conversation: conversation ?? this.conversation,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      selectedMessages: selectedMessages ?? this.selectedMessages,
      participants: participants ?? this.participants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initial: initial ?? this.initial,
      choose: choose ?? this.choose,
      typingStatus: typingStatus,
      replyIdToScroll: replyIdToScroll ?? this.replyIdToScroll,
      draftMessage: draftMessage != null ? draftMessage() : this.draftMessage,
      replyMessage: replyMessage != null ? replyMessage() : this.replyMessage,
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
        selectedMessages,
        hasReachedMax,
        initial,
        choose,
        replyIdToScroll,
        participants,
        typingStatus,
        draftMessage,
        replyMessage
      ];
}
