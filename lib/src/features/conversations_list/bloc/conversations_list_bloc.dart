import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:equatable/equatable.dart';

import '../../../db/models/conversation.dart';
import '../../../repository/conversation/conversation_repository.dart';

part 'conversations_list_event.dart';

part 'conversations_list_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc({
    required ConversationRepository conversationRepository,
  })  : _conversationRepository = conversationRepository,
        super(const ConversationState()) {
    on<ConversationFetched>(
      _onConversationFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final ConversationRepository _conversationRepository;

  Future<void> _onConversationFetched(
      ConversationFetched event, Emitter<ConversationState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == ConversationStatus.initial) {
        final conversations =
            await _conversationRepository.getConversationsWithParticipants();
        return emit(
          state.copyWith(
            status: ConversationStatus.success,
            conversations: conversations,
            hasReachedMax:
                true, //FixME RP when if pagination will be implemented
          ),
        );
      }

      final List<ConversationModel> conversations =
          await _conversationRepository.getConversationsWithParticipants();

      conversations.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: ConversationStatus.success,
                conversations: List.of(state.conversations)
                  ..addAll(conversations),
                hasReachedMax: false,
              ),
            );
    } catch (err) {
      print("_onConversationFetched err= $err");
      emit(state.copyWith(status: ConversationStatus.failure));
    }
  }
}
