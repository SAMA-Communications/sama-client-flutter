import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../api/api.dart';
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
  ConversationModel currentConversation;
  final ConversationRepository conversationRepository;
  final MessagesRepository messagesRepository;
  final UserRepository userRepository;

  StreamSubscription<ConversationModel>? updateConversationStreamSubscription;
  StreamSubscription<ChatMessage>? incomingMessagesSubscription;

  ConversationBloc({
    required this.currentConversation,
    required this.conversationRepository,
    required this.messagesRepository,
    required this.userRepository,
  }) : super(ConversationState(conversation: currentConversation)) {
    on<MessagesRequested>(
      _onMessagesRequested,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ParticipantsReceived>(
      _onParticipantsReceived,
    );
    on<_MessageReceived>(
      _onMessageReceived,
    );
    on<_ConversationUpdated>(
      _onConversationUpdated,
    );
    on<ConversationDeleted>(
      _onConversationDeleted,
    );

    add(const ParticipantsReceived());

    updateConversationStreamSubscription =
        conversationRepository.updateConversationStream.listen((chat) async {
      if (chat.id != currentConversation.id) return;

      if (currentConversation != chat) {
        currentConversation = currentConversation.copyWithItem(item: chat);
        add(_ConversationUpdated(currentConversation));
      }
    });

    incomingMessagesSubscription =
        messagesRepository.incomingMessagesStream.listen((message) async {
      if (message.cid != currentConversation.id) return;

      add(_MessageReceived(message));
    });
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
    return messagesRepository.getMessages(currentConversation.id, parameters: {
      if (ltDate != null)
        'updated_at': {
          'lt': ltDate.toIso8601String(),
        },
      if (gtTime != null)
        'updated_at': {
          'gt': gtTime.toIso8601String(),
        },
    });
  }

  Future<void> _onParticipantsReceived(
      ParticipantsReceived event, Emitter<ConversationState> emit) async {
    var participants =
        await conversationRepository.getParticipants([currentConversation.id]);
    emit(state.copyWith(participants: Set.of(participants)));
  }

  Future<void> _onConversationUpdated(
      _ConversationUpdated event, Emitter<ConversationState> emit) async {
    emit(state.copyWith(conversation: event.conversation));
  }

  Future<void> _onConversationDeleted(
      ConversationDeleted event, Emitter<ConversationState> emit) async {
    await conversationRepository.deleteConversation(state.conversation)
        ? emit(state.copyWith(status: ConversationStatus.delete))
        : emit(state.copyWith(status: ConversationStatus.failure));
  }

  FutureOr<void> _onMessageReceived(
      _MessageReceived event, Emitter<ConversationState> emit) {
    var messages = [...state.messages];

    if (messages.isNotEmpty) {
      messages.first = messages.first.copyWith(
        isLastUserMessage: isServiceMessage(messages.first) ||
            event.message.from != messages.first.from,
        isFirstUserMessage: messages.length == 1 ||
            isServiceMessage(messages[1]) ||
            messages[1].from != messages.first.from,
      );
    }

    messages.insert(
      0,
      event.message.copyWith(
        isFirstUserMessage: messages.isEmpty ||
            isServiceMessage(messages.first) ||
            event.message.from != messages.first.from,
        isLastUserMessage: true,
      ),
    );

    emit(state.copyWith(messages: messages));
  }

  @override
  Future<void> close() {
    updateConversationStreamSubscription?.cancel();
    incomingMessagesSubscription?.cancel();
    return super.close();
  }
}
