part of 'conversations_list_bloc.dart';

enum ConversationsStatus { initial, success, failure }

class TypingChatStatus {
  final TypingState typingState;
  final ConversationModel? chat;
  final UserModel? user;

  TypingChatStatus(this.typingState, this.chat, this.user);
}

final class ConversationsState extends Equatable {
  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const <ConversationModel>[],
    this.hasReachedMax = false,
    this.initial = false,
    this.typingStatuses = const <String, TypingChatStatus>{},
  });

  final ConversationsStatus status;
  final List<ConversationModel> conversations;
  final bool hasReachedMax;
  final bool initial;
  final Map<String, TypingChatStatus> typingStatuses;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationModel>? conversations,
    bool? hasReachedMax,
    bool? initial,
    Map<String, TypingChatStatus>? typingStatuses,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initial: initial ?? this.initial,
      typingStatuses: typingStatuses ?? this.typingStatuses,
    );
  }

  @override
  String toString() {
    return '''ConversationsState { status: $status, hasReachedMax: $hasReachedMax, initial: $initial, conversations: ${conversations.length}}''';
  }

  @override
  List<Object?> get props =>
      [status, conversations, hasReachedMax, initial, typingStatuses];
}
