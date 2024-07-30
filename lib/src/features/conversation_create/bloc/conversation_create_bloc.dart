import 'package:bloc/bloc.dart';
import 'package:sama_client_flutter/src/repository/conversation/conversation_repository.dart';

import 'conversation_create_event.dart';
import 'conversation_create_state.dart';

class ConversationCreateBloc
    extends Bloc<ConversationCreateEvent, ConversationCreateState> {
  ConversationCreateBloc({required this.conversationRepository})
      : super(ConversationCreatedLoading()) {
    on<ConversationCreated>(_onConversationCreated);
  }

  final ConversationRepository conversationRepository;

  Future<void> _onConversationCreated(
    ConversationCreated event,
    Emitter<ConversationCreateState> emit,
  ) async {
    final user = event.user;
    final type = event.type;
    emit(ConversationCreatedLoading());

    try {
      final conversation =
          await conversationRepository.createConversation([user], type);
      emit(ConversationCreatedState(conversation));
    } catch (error) {
      emit(
        error is ConversationCreatedStateError
            ? ConversationCreatedStateError(error.error)
            : const ConversationCreatedStateError('something went wrong'),
      );
    }
  }
}
