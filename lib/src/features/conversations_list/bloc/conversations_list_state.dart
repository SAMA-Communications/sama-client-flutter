part of 'conversations_list_bloc.dart';

enum ConversationsStatus { initial, success, failure }

final class ConversationsState extends Equatable {
  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const <ConversationModel>[],
    this.hasReachedMax = false,
    this.initial = false,
  });

  final ConversationsStatus status;
  final List<ConversationModel> conversations;
  final bool hasReachedMax;
  final bool initial;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationModel>? conversations,
    bool? hasReachedMax,
    bool? initial,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      initial: initial ?? this.initial,
    );
  }

  @override
  String toString() {
    return '''ConversationsState { status: $status, hasReachedMax: $hasReachedMax, initial: $initial, conversations: ${conversations.length} }''';
  }

  @override
  List<Object> get props => [status, conversations, hasReachedMax, initial];
}
