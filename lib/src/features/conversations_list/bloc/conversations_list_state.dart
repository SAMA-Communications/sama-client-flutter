part of 'conversations_list_bloc.dart';

enum ConversationsStatus { initial, success, failure }

final class ConversationsState extends Equatable {
  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const <ConversationModel>[],
    this.hasReachedMax = false,
  });

  final ConversationsStatus status;
  final List<ConversationModel> conversations;
  final bool hasReachedMax;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationModel>? conversations,
    bool? hasReachedMax,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ConversationsState { status: $status, hasReachedMax: $hasReachedMax, conversations: ${conversations.length} }''';
  }

  @override
  List<Object> get props => [status, conversations, hasReachedMax];
}
