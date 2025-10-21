import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../api/api.dart';
import '../../../../db/models/models.dart';
import '../../../../repository/messages/messages_repository.dart';

part 'ai_message_event.dart';

part 'ai_message_state.dart';

class AiMessageBloc extends Bloc<AiMessageEvent, AiMessageState> {
  final MessagesRepository messagesRepository;
  final ConversationModel currentConversation;

  AiMessageBloc({
    required this.currentConversation,
    required this.messagesRepository,
  }) : super(const AiMessageState()) {
    on<GetMessagesSummary>(
      _onGetMessagesSummary,
    );
    on<GetMessageTone>(
      _onGetMessageTone,
    );
  }

  Future<FutureOr<void>> _onGetMessagesSummary(
      GetMessagesSummary event, Emitter<AiMessageState> emit) async {
    try {
      emit(state.copyWith(status: AiMessageStatus.processing));
      await messagesRepository.getMessagesSummary(
          currentConversation.id, event.filter);
      emit(state.copyWith(status: AiMessageStatus.success));
    } on ResponseException catch (ex) {
      emit(state.copyWith(
          errorMessage: ex.message, status: AiMessageStatus.failure));
    }
  }

  Future<FutureOr<void>> _onGetMessageTone(
      GetMessageTone event, Emitter<AiMessageState> emit) async {
    try {
      emit(state.copyWith(status: AiMessageStatus.processing));
      var message = await messagesRepository.changeMessageTone(
          event.message, event.filter);
      emit(state.copyWith(text: message, status: AiMessageStatus.success));
    } catch (_) {}
  }
}
