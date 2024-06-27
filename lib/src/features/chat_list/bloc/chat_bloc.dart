import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:equatable/equatable.dart';

import '../../../db/models/chat.dart';
import '../../../repository/chat/chat_repository.dart';

part 'chat_event.dart';

part 'chat_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const ChatState()) {
    on<ChatFetched>(
      _onChatFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final ChatRepository _chatRepository;

  Future<void> _onChatFetched(
      ChatFetched event, Emitter<ChatState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == ChatStatus.initial) {
        final chats = await _chatRepository.getChatsWithParticipants();
        return emit(
          state.copyWith(
            status: ChatStatus.success,
            chats: chats,
            hasReachedMax: true, //FixME RP when if pagination will be implemented
          ),
        );
      }

      final List<ChatModel> chats = await _chatRepository.getChatsWithParticipants();

      chats.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: ChatStatus.success,
                chats: List.of(state.chats)..addAll(chats),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      emit(state.copyWith(status: ChatStatus.failure));
    }
  }
}
