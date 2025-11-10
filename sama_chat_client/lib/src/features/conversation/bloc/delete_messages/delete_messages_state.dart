part of 'delete_messages_bloc.dart';

enum DeleteMessagesStatus { initial, processing, success, failure }

final class DeleteMessagesState extends Equatable {
  const DeleteMessagesState({
    this.status = DeleteMessagesStatus.initial,
    this.messagesToDelete = const [],
    this.errorMessage,
  });

  final DeleteMessagesStatus status;
  final List<ConversationModel> messagesToDelete;

  final String? errorMessage;

  DeleteMessagesState copyWith({
    DeleteMessagesStatus? status,
    List<ConversationModel>? messagesToDelete,
    String? errorMessage,
  }) {
    return DeleteMessagesState(
      status: status ?? this.status,
      messagesToDelete: messagesToDelete ?? this.messagesToDelete,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return '''DeleteMessagesState { status: $status}''';
  }

  @override
  List<Object?> get props => [
        status,
        messagesToDelete,
        errorMessage,
      ];
}
