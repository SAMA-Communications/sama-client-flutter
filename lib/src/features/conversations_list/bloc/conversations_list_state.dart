part of 'conversations_list_bloc.dart';

enum ConversationStatus { initial, success, failure }

final class ConversationState extends Equatable {
  const ConversationState({
    this.status = ConversationStatus.initial,
    this.conversations = const <ConversationModel>[],
    this.hasReachedMax = false,
  });

  final ConversationStatus status;
  final List<ConversationModel> conversations;
  final bool hasReachedMax;

  ConversationState copyWith({
    ConversationStatus? status,
    List<ConversationModel>? conversations,
    bool? hasReachedMax,
  }) {
    return ConversationState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ConversationState { status: $status, hasReachedMax: $hasReachedMax, conversations: ${conversations.length} }''';
  }

  @override
  List<Object> get props => [status, conversations, hasReachedMax];
}
