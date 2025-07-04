part of 'forward_messages_bloc.dart';

enum ForwardMessagesStatus { initial, processing, success, failure }

final class ForwardMessagesState extends Equatable {
  const ForwardMessagesState({
    this.status = ForwardMessagesStatus.initial,
    this.chats = const [],
    this.errorMessage,
  });

  final ForwardMessagesStatus status;
  final List<ConversationModel> chats;

  final String? errorMessage;

  ForwardMessagesState copyWith({
    ForwardMessagesStatus? status,
    List<ConversationModel>? chats,
    String? errorMessage,
  }) {
    return ForwardMessagesState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return '''ForwardMessageState { status: $status}''';
  }

  @override
  List<Object?> get props => [
        status,
        chats,
        errorMessage,
      ];
}
