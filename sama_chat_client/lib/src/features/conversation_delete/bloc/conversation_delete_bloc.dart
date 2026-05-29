import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../db/models/conversation_model.dart';

part 'conversation_delete_event.dart';

part 'conversation_delete_state.dart';
//Add this to conversation instead of _onConversationDeleted in ConversationBloc
class ConversationDeleteBloc
    extends Bloc<ConversationDeleteEvent, ConversationDeleteState> {
  ConversationDeleteBloc({required this.conversationRepository})
      : super(const ConversationDeleteState()) {
    on<ConversationDeleted>(_onConversationDeleted);
  }

  final ConversationRepository conversationRepository;

  Future<void> _onConversationDeleted(
    ConversationDeleted event,
    Emitter<ConversationDeleteState> emit,
  ) async {
    await conversationRepository.deleteConversation(event.chat)
        ? emit(state.copyWith(status: ConversationDeleteStatus.success))
        : emit(state.copyWith(
            status: ConversationDeleteStatus.failure,
            errorMessage: 'Conversation deletion failed.'));
  }
}
