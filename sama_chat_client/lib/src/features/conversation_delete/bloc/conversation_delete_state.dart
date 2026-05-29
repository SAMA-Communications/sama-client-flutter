part of 'conversation_delete_bloc.dart';

enum ConversationDeleteStatus { initial, success, failure }

final class ConversationDeleteState extends Equatable {
  const ConversationDeleteState({
    this.status = ConversationDeleteStatus.initial,
    this.errorMessage,
    this.informationMessage,
  });

  final ConversationDeleteStatus status;
  final String? errorMessage;
  final String? informationMessage;

  ConversationDeleteState copyWith({
    ConversationDeleteStatus? status,
    ConversationModel? conversation,
    String? errorMessage,
    String? informationMessage,
  }) {
    return ConversationDeleteState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      informationMessage: informationMessage ?? this.informationMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, informationMessage];
}
