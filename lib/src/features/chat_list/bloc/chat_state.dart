part of 'chat_bloc.dart';

enum ChatStatus { initial, success, failure }

final class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.chats = const <ChatModel>[],
    this.hasReachedMax = false,
  });

  final ChatStatus status;
  final List<ChatModel> chats;
  final bool hasReachedMax;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatModel>? chats,
    bool? hasReachedMax,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ChatState { status: $status, hasReachedMax: $hasReachedMax, chats: ${chats.length} }''';
  }

  @override
  List<Object> get props => [status, chats, hasReachedMax];
}