import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../api/api.dart';
import '../../../db/models/models.dart';
import '../../../db/resource.dart';
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

EventTransformer<Event> debounce<Event>({
  Duration duration = const Duration(milliseconds: 500),
}) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationModel currentConversation;
  final ConversationRepository conversationRepository;
  final MessagesRepository messagesRepository;
  final UserRepository userRepository;

  StreamSubscription<ChatMessage>? incomingMessagesSubscription;
  StreamSubscription<MessageSendStatus>? statusMessagesSubscription;
  StreamSubscription<ConversationModel?>? conversationWatcher;

  ConversationBloc({
    required this.currentConversation,
    required this.conversationRepository,
    required this.messagesRepository,
    required this.userRepository,
  }) : super(ConversationState(
            conversation: currentConversation,
            participants: Set.of(currentConversation.participants))) {
    on<MessagesRequested>(_onMessagesRequested);
    on<MessagesMoreRequested>(
      _onMessagesMoreRequested,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ParticipantsReceived>(
      _onParticipantsReceived,
    );
    on<_MessageReceived>(
      _onMessageReceived,
    );
    on<_PendingStatusReceived>(
      _onPendingStatusReceived,
    );
    on<_SentStatusReceived>(
      _onSentStatusReceived,
    );
    on<_ReadStatusReceived>(
      _onReadStatusReceived,
      transformer: debounce(),
    );
    on<_ConversationUpdated>(
      _onConversationUpdated,
    );
    on<ConversationDeleted>(
      _onConversationDeleted,
    );

    add(const ParticipantsReceived());

    incomingMessagesSubscription =
        messagesRepository.incomingMessagesStream.listen((message) async {
      if (message.cid != currentConversation.id) return;

      add(_MessageReceived(message));

      switch (message.extension?['type']) {
        case 'added_participant':
        case 'removed_participant':
        case 'left_participants':
          add(const ParticipantsReceived());
      }
    });

    statusMessagesSubscription =
        messagesRepository.statusMessagesStream.listen((status) async {
      switch (status) {
        case PendingMessageStatus():
          add(_PendingStatusReceived(status));
          break;
        case SentMessageStatus():
          add(_SentStatusReceived(status));
          break;
        case ReadMessagesStatus():
          add(_ReadStatusReceived(status));
          break;
      }
    });

    conversationWatcher = messagesRepository.localDatasource
        .watchedConversation(currentConversation.id)
        .listen((chat) {
      if (chat != null && chat != currentConversation) {
        currentConversation = currentConversation.copyWithItem(item: chat);
        add(_ConversationUpdated(currentConversation));
      }
    });
  }

  Future<void> _onMessagesRequested(
    MessagesRequested event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      if (state.status == ConversationStatus.initial) {
        final messages =
            await messagesRepository.getStoredMessages(currentConversation);
        emit(
          state.copyWith(
              status: ConversationStatus.success,
              messages: messages,
              hasReachedMax: false,
              participants: Set.of(currentConversation.participants),
              initial: true),
        );
        add(const MessagesRequested());
        return;
      }
      await _getAllMessages(emit, force: event.force);
    } catch (e) {
      log('[ConversationBloc]', stringData: e.toString());
      emit(state.copyWith(status: ConversationStatus.failure));
    }
  }

  Future<void> _onMessagesMoreRequested(
    MessagesMoreRequested event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.hasReachedMax && !state.initial) return;
    try {
      await _getAllMessages(emit, ltDate: state.messages.lastOrNull?.createdAt);
    } catch (e) {
      log('[ConversationBloc]', stringData: e.toString());
      emit(state.copyWith(status: ConversationStatus.failure));
    }
  }

  _getAllMessages(Emitter<ConversationState> emit,
      {bool force = false, DateTime? ltDate, DateTime? gtTime}) async {
    var resource = await messagesRepository.getAllMessages(currentConversation,
        ltDate: ltDate, gtTime: gtTime);
    switch (resource.status) {
      case Status.success:
        var messages = resource.data ?? List.empty();
        messages.isEmpty
            ? emit(state.copyWith(hasReachedMax: true, initial: false))
            : emit(
                state.copyWith(
                  status: ConversationStatus.success,
                  messages: state.initial || force
                      ? List.of(messages)
                      : (List.of(state.messages)..addAll(messages)),
                  hasReachedMax: false,
                  initial: false,
                ),
              );
        break;
      case Status.failed:
        emit(state.copyWith(status: ConversationStatus.failure));
        break;
      case Status.loading:
        break;
    }
  }

  Future<void> _onParticipantsReceived(
      ParticipantsReceived event, Emitter<ConversationState> emit) async {
    var participants = await conversationRepository
        .updateParticipants(currentConversation.copyWith());
    emit(state.copyWith(participants: Set.of(participants)));
  }

  Future<void> _onConversationUpdated(event, emit) async {
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

    emit(
        state.copyWith(messages: messages, status: ConversationStatus.success));
  }

  Future<void> _onPendingStatusReceived(
      _PendingStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = [...state.messages];

    var msg = messages.firstWhere((o) => o.id == event.status.messageId);
    var msgUpdated = msg.copyWith(status: ChatMessageStatus.pending);
    messages[messages.indexOf(msg)] = msgUpdated;
    emit(state.copyWith(messages: messages));
  }

  FutureOr<void> _onSentStatusReceived(
      _SentStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = [...state.messages];

    var msg = messages.firstWhere((o) => o.id == event.status.messageId);
    var msgUpdated = msg.copyWith(
        id: event.status.serverMessageId, status: ChatMessageStatus.sent);
    messages[messages.indexOf(msg)] = msgUpdated;
    var msgLocal = await messagesRepository.updateMessageLocal(msgUpdated);
    conversationRepository.updateConversationLocal(currentConversation.copyWith(
        lastMessage: msgLocal, updatedAt: msgLocal.createdAt));
    emit(state.copyWith(messages: messages));
  }

  FutureOr<void> _onReadStatusReceived(
      _ReadStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = {for (var v in state.messages) v.id!: v};
    var msgListUpdated = <MessageModel>[];
    event.status.msgIds?.forEach((id) {
      if (messages[id] != null &&
          messages[id]?.status != ChatMessageStatus.read) {
        var msg = messages[id]!.copyWith(status: ChatMessageStatus.read);
        messages[id] = msg;
        msgListUpdated.add(msg);
      }
    });
    await messagesRepository.updateMessagesLocal(msgListUpdated);
    // TODO RP CHECK ME
    // conversationRepository.updateConversationLocal(
    //     currentConversation, msgListUpdated.last);
    emit(state.copyWith(messages: messages.values.toList()));
  }

  @override
  Future<void> close() {
    incomingMessagesSubscription?.cancel();
    statusMessagesSubscription?.cancel();
    conversationWatcher?.cancel();
    return super.close();
  }
}
