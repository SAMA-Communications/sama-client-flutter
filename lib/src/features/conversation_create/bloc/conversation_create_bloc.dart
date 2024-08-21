import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

import 'conversation_create_event.dart';
import 'conversation_create_state.dart';
import '../../../repository/conversation/conversation_repository.dart';

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
      var conversation = conversationRepository.localDataSource
          .getConversationsList()
          .firstWhereOrNull((item) =>
              item.type == type &&
              (item.opponent?.id == user.id || item.owner?.id == user.id));
      conversation ??=
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
