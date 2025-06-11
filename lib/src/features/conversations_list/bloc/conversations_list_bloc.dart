import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../api/api.dart';
import '../../../db/models/conversation_model.dart';
import '../../../db/models/models.dart';
import '../../../db/resource.dart';
import '../../../repository/conversation/conversation_repository.dart';

part 'conversations_list_event.dart';

part 'conversations_list_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final ConversationRepository _conversationRepository;
  StreamSubscription<ConversationModel>? updateConversationStreamSubscription;
  StreamSubscription<TypingStatus>? typingSubscription;

  ConversationsBloc({
    required ConversationRepository conversationRepository,
  })  : _conversationRepository = conversationRepository,
        super(const ConversationsState()) {
    on<ConversationsFetched>(_onConversationsFetched);
    on<ConversationsMoreFetched>(
      _onConversationsMoreFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ConversationsRefreshed>(
      _onConversationsRefreshed,
    );
    on<TypingStatusStartReceived>(
      _onTypingStatusStartReceived,
    );
    on<TypingStatusStopReceived>(
      _onTypingStatusStopReceived,
    );

    updateConversationStreamSubscription =
        conversationRepository.updateConversationStream.listen((chat) async {
      if (!isClosed) {
        add(ConversationsRefreshed());

        if (state.typingStatuses.containsKey(chat.id)) {
          add(TypingStatusStopReceived(chat.id, chat.lastMessage!.from!));
        }
      }
    });

    typingSubscription =
        conversationRepository.typingMessageStream.listen((typing) async {
      if (typing.state == TypingState.start) {
        add(TypingStatusStartReceived(typing.cid!, typing.from!));
      } else if (typing.state == TypingState.stop) {
        add(TypingStatusStopReceived(typing.cid!, typing.from!));
      }
    });
  }

  Future<void> _onConversationsFetched(event, emit) async {
    try {
      if (state.status == ConversationsStatus.initial && !event.force) {
        final conversations =
            await _conversationRepository.getStoredConversations();
        return emit(
          state.copyWith(
              status: ConversationsStatus.success,
              conversations: conversations,
              hasReachedMax: true,
              initial: true),
        );
      }
      await _getAllConversations(emit, force: event.force);
    } catch (err) {
      print("_onConversationFetched err= $err");
      if (state.conversations.isEmpty) {
        emit(state.copyWith(status: ConversationsStatus.failure));
      }
    }
  }

  Future<void> _onConversationsMoreFetched(event, emit) async {
    if (state.hasReachedMax && !state.initial) return;
    try {
      await _getAllConversations(emit,
          ltDate: state.conversations.lastOrNull?.createdAt);
    } catch (err) {
      print("_onConversationFetched err= $err");
      if (state.conversations.isEmpty) {
        emit(state.copyWith(status: ConversationsStatus.failure));
      }
    }
  }

  _getAllConversations(Emitter<ConversationsState> emit,
      {bool force = false, DateTime? ltDate}) async {
    var resource =
        await _conversationRepository.getAllConversations(ltDate: ltDate);
    switch (resource.status) {
      case Status.success:
        var conversations = resource.data ?? List.empty();
        conversations.isEmpty
            ? emit(state.copyWith(hasReachedMax: true, initial: false))
            : emit(
                state.copyWith(
                  status: ConversationsStatus.success,
                  conversations: state.initial || force
                      ? List.of(conversations)
                      : (List.of(state.conversations)..addAll(conversations)),
                  hasReachedMax: false,
                  initial: false,
                ),
              );
        break;
      case Status.failed:
        emit(state.copyWith(status: ConversationsStatus.failure));
        break;
      case Status.loading:
        break;
    }
  }

  Future<void> _onConversationsRefreshed(
      ConversationsRefreshed event, Emitter<ConversationsState> emit) async {
    final conversations =
        await _conversationRepository.getStoredConversations();
    return emit(
      state.copyWith(
          status: ConversationsStatus.success,
          conversations: conversations,
          hasReachedMax: true),
    );
  }

  Future<void> _onTypingStatusStartReceived(
      TypingStatusStartReceived event, Emitter<ConversationsState> emit) async {
    final chatAsync = _conversationRepository.getConversationById(event.cid);
    var userAsync = _conversationRepository.getConversationUser(event.from);
    List responses = await Future.wait([chatAsync, userAsync]);
    var typingStatus = Map.of(state.typingStatuses);
    typingStatus[event.cid] =
        TypingChatStatus(TypingState.start, responses.first, responses.last);
    return emit(state.copyWith(typingStatuses: typingStatus));
  }

  Future<void> _onTypingStatusStopReceived(
      TypingStatusStopReceived event, Emitter<ConversationsState> emit) async {
    final chatAsync = _conversationRepository.getConversationById(event.cid);
    var userAsync = _conversationRepository.getConversationUser(event.from);
    List responses = await Future.wait([chatAsync, userAsync]);
    var typingStatus = Map.of(state.typingStatuses);
    typingStatus[event.cid] =
        TypingChatStatus(TypingState.stop, responses.first, responses.last);
    return emit(state.copyWith(typingStatuses: typingStatus));
  }

  @override
  Future<void> close() {
    updateConversationStreamSubscription?.cancel();
    typingSubscription?.cancel();
    return super.close();
  }
}
