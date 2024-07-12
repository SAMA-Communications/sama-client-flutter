import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../api/users/models/models.dart';
import '../../../api/utils/logger.dart';
import '../../../db/models/conversation.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/messages/messages_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../models/models.dart';

part 'conversation_event.dart';

part 'conversation_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationModel currentConversation;
  final ConversationRepository conversationRepository;
  final MessagesRepository messagesRepository;
  final UserRepository userRepository;

  ConversationBloc({
    required this.currentConversation,
    required this.conversationRepository,
    required this.messagesRepository,
    required this.userRepository,
  }) : super(const ConversationState()) {
    on<MessagesRequested>(
      _onMessagesRequested,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ParticipantsRequested>(
      _onParticipantsRequested,
    );
  }

  Future<void> _onMessagesRequested(
    MessagesRequested event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == ConversationStatus.initial) {
        final messages = await _fetchMessages();
        return emit(
          state.copyWith(
            status: ConversationStatus.success,
            messages: messages,
            hasReachedMax: false,
          ),
        );
      }

      final messages =
          await _fetchMessages(ltDate: state.messages.last.createdAt);
      messages.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: ConversationStatus.success,
                messages: List.of(state.messages)..addAll(messages),
                hasReachedMax: false,
              ),
            );
    } catch (e) {
      log('[ConversationBloc]', stringData: e.toString());
      emit(state.copyWith(status: ConversationStatus.failure));
    }
  }

  Future<List<ChatMessage>> _fetchMessages(
      {DateTime? ltDate, DateTime? gtTime}) async {
    var messages = await messagesRepository
        .getMessages(currentConversation.id, parameters: {
      if (ltDate != null)
        'updated_at': {
          'lt': ltDate.toIso8601String(),
        },
      if (gtTime != null)
        'updated_at': {
          'gt': gtTime.toIso8601String(),
        },
    });

    var currentUser = await userRepository.getUser();

    var result = <ChatMessage>[];

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      var sender = state.participants
          .where((participant) => participant.id == message.from)
          .first;

      var chatMessage = ChatMessage(
          sender: sender,
          isOwn: currentUser?.id == message.from,
          isFirst: i == 0 || messages[i - 1].from != sender.id,
          isLast: i == messages.length - 1 || messages[i + 1].from != sender.id,
          id: message.id,
          from: message.from,
          cid: message.cid,
          status: message.status,
          body: message.body,
          attachments: message.attachments,
          createdAt: message.createdAt,
          t: message.t,
          extension: message.extension);

      result.add(chatMessage);
    }

    return result;
  }

  Future<void> _onParticipantsRequested(
      ParticipantsRequested event, Emitter<ConversationState> emit) async {
    try {
      var participants = await conversationRepository
          .getParticipants([currentConversation.id]);
      emit(state.copyWith(participants: participants));
    } catch (_) {}
  }
}
