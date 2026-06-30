import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:sama_sdk/api/api.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../db/models/models.dart';
import '../../../db/resource.dart';
import '../../../repository/conversation/conversation_repository.dart';
import '../../../repository/messages/messages_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../../../shared/utils/list_utils.dart';
import '../models/models.dart';

part 'conversation_event.dart';

part 'conversation_state.dart';

const messagesThrottleDuration = Duration(milliseconds: 100);
const scrollThrottleDuration = Duration(milliseconds: 1000);
const scrollToReplyTimeout = Duration(seconds: 7);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

EventTransformer<E> typingThrottleDroppable<E>() {
  Duration duration = const Duration(milliseconds: 5000);
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

EventTransformer<Event> readDebounce<Event>({
  Duration duration = const Duration(milliseconds: 500),
}) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationModel currentConversation;
  final ConversationRepository conversationRepository;
  final MessagesRepository messagesRepository;
  final UserRepository userRepository;

  StreamSubscription<MessageModel>? incomingMessagesSubscription;
  StreamSubscription<MessageSendStatus>? statusMessagesSubscription;
  StreamSubscription<TypingStatus>? typingMessageSubscription;
  StreamSubscription<Map<String, dynamic>>? lastActivitySubscription;
  StreamSubscription<ConversationModel?>? conversationWatcher;

  Timer? headerTimer;

  ConversationBloc({
    required this.currentConversation,
    required this.conversationRepository,
    required this.messagesRepository,
    required this.userRepository,
  }) : super(ConversationState(
            conversation: currentConversation,
            unreadMessagesCount: currentConversation.unreadMessagesCount ?? 0,
            unreadIndex:
                max(0, ((currentConversation.unreadMessagesCount ?? 0) - 1)),
            participants: Set.of(currentConversation.participants))) {
    on<MessagesRequested>(_onMessagesRequested);
    on<MessagesMoreRequested>(
      _onMessagesMoreRequested,
      transformer: throttleDroppable(messagesThrottleDuration),
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
    on<_EditStatusReceived>(
      _onEditStatusReceived,
    );
    on<_DeleteStatusReceived>(
      _onDeleteStatusReceived,
    );
    on<_SentStatusReceived>(
      _onSentStatusReceived,
    );
    on<_ReadStatusReceived>(
      _onReadStatusReceived,
      transformer: readDebounce(),
    );
    on<_FailedStatusReceived>(
      _onFailedStatusReceived,
    );
    on<_ConversationUpdated>(
      _onConversationUpdated,
    );
    on<ConversationDeleted>(
      _onConversationDeleted,
    );
    on<TypingStatusStartReceived>(
      _onTypingStatusStartReceived,
      transformer: typingThrottleDroppable(),
    );
    on<TypingStatusStopReceived>(
      _onTypingStatusStopReceived,
    );
    on<ReplyMessageRequired>(
      _onReplyMessageRequired,
    );
    on<MessagesMoreForReply>(
      onMessagesMoreForReply,
    );
    on<RemoveMessagesMoreForReply>(
      onRemoveMessagesMoreForReply,
    );
    on<SelectMessagesMode>(
      onSelectMessagesMode,
    );
    on<SelectedChatsAdded>(
      onSelectedChatsAdded,
    );
    on<SelectedChatsRemoved>(
      onSelectedChatsRemoved,
    );
    on<ShowDateHeader>(
      onShowHeader,
      transformer: throttleDroppable(scrollThrottleDuration),
    );
    on<HideDateHeader>(
      onHideHeader,
    );
    on<ResetUnreadCount>(
      onResetUnreadCount,
    );
    on<ResetUnreadIndex>(
      onResetUnreadIndex,
    );

    add(const ParticipantsReceived());

    subscribeOpponentLastActivity();

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
        case EditMessageStatus():
          add(_EditStatusReceived(status));
          break;
        case DeleteMessagesStatus():
          add(_DeleteStatusReceived(status));
          break;
        case SentMessageStatus():
          add(_SentStatusReceived(status));
          break;
        case ReadMessagesStatus():
          add(_ReadStatusReceived(status));
          break;
        case FailedMessagesStatus():
          add(_FailedStatusReceived(status));
          break;
      }
    });

    typingMessageSubscription =
        messagesRepository.typingMessageStream.listen((typing) async {
      if (typing.cid == currentConversation.id) {
        if (typing.state == TypingState.start) {
          add(TypingStatusStartReceived(typing.from!));
        } else if (typing.state == TypingState.stop) {
          add(TypingStatusStopReceived(typing.from!));
        }
      }
    });

    lastActivitySubscription =
        userRepository.lastActivityStream.listen((data) async {
      var recentActivity = data[currentConversation.opponent?.id];
      _updateOpponentRecentActivity(recentActivity);
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

  subscribeOpponentLastActivity() async {
    if (currentConversation.type == 'u' &&
        currentConversation.opponent != null) {
      var recentActivity = await userRepository
          .subscribeUserLastActivity(currentConversation.opponent!.id!);
      _updateOpponentRecentActivity(recentActivity);
    }
  }

  _updateOpponentRecentActivity(int recentActivity) {
    currentConversation = currentConversation.copyWith(
        opponent: currentConversation.opponent
            ?.copyWith(recentActivity: recentActivity));

    add(_ConversationUpdated(currentConversation));
  }

  unsubscribeOpponentLastActivity() async {
    if (currentConversation.type == 'u') {
      userRepository.unsubscribeUserLastActivity();
    }
  }

  Future<void> _onMessagesRequested(
    MessagesRequested event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      if (state.status == ConversationStatus.initial) {
        final messages = await buildChatMessageModels(
            await messagesRepository.getStoredMessages(currentConversation.id));
        if (messages.length >= state.unreadMessagesCount) {
          emit(
            state.copyWith(
                status: ConversationStatus.success,
                messages: messages,
                scroll: false,
                hasReachedMax: false,
                participants: Set.of(currentConversation.participants),
                initial: true),
          );
          add(const MessagesRequested());
          return;
        } else {
          emit(
            state.copyWith(
                hasReachedMax: false,
                participants: Set.of(currentConversation.participants),
                initial: true),
          );
        }
      }
      await _getAllMessages(emit, refresh: event.refresh);
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
      {bool refresh = false, DateTime? ltDate, DateTime? gtTime}) async {
    var resource = await messagesRepository.getAllMessages(currentConversation,
        ltDate: ltDate, gtTime: gtTime);
    switch (resource.status) {
      case Status.success:
        var messages =
            await buildChatMessageModels(resource.data ?? List.empty());

        var totalMessagesLength = state.messages.length + messages.length;
        if (totalMessagesLength >= state.unreadMessagesCount) {
          messages.isEmpty
              ? emit(state.copyWith(hasReachedMax: true, initial: false))
              : emit(
                  state.copyWith(
                    status: ConversationStatus.success,
                    messages: state.initial || refresh
                        ? List.of(messages)
                        : (List.of(state.messages)..addAll(messages)),
                    hasReachedMax: false,
                    scroll: false,
                    initial: false,
                  ),
                );
        } else {
          emit(
            state.copyWith(
              messages: state.initial || refresh
                  ? List.of(messages)
                  : (List.of(state.messages)..addAll(messages)),
              hasReachedMax: false,
              scroll: false,
              initial: false,
            ),
          );
          add(const MessagesMoreRequested());
        }
        break;
      case Status.failed:
        emit(state.copyWith(status: ConversationStatus.failure));
        break;
      case Status.loading:
        break;
    }
  }

  Future<void> onShowHeader(event, emit) async {
    emit(state.copyWith(showDateHeader: true));

    headerTimer?.cancel();

    headerTimer = Timer(const Duration(seconds: 3), () {
      add(const HideDateHeader());
    });
  }

  void onHideHeader(event, emit) {
    emit(state.copyWith(showDateHeader: false));
  }

  void onResetUnreadCount(event, emit) {
    emit(state.copyWith(unreadMessagesCount: 0));
  }

  void onResetUnreadIndex(event, emit) {
    emit(state.copyWith(unreadIndex: 0));
  }

  Future<void> _onParticipantsReceived(
      ParticipantsReceived event, Emitter<ConversationState> emit) async {
    var participants =
        await conversationRepository.updateParticipants(currentConversation.id);
    await conversationRepository.updateConversationLocal(
        currentConversation.copyWith(participants: participants));
    if (currentConversation.opponent?.recentActivity == 0) {
      var index = participants
          .indexWhere((i) => i.id == currentConversation.opponent?.id);
      participants[index] = participants[index].copyWith(recentActivity: 0);
    }
    emit(state.copyWith(participants: Set.of(participants)));
  }

  Future<void> _onConversationUpdated(event, emit) async {
    emit(state.copyWith(
        conversation: event.conversation,
        unreadMessagesCount: event.conversation.unreadMessagesCount));
  }

  Future<void> _onConversationDeleted(
      ConversationDeleted event, Emitter<ConversationState> emit) async {
    await conversationRepository.deleteConversation(state.conversation)
        ? emit(state.copyWith(status: ConversationStatus.delete))
        : emit(state.copyWith(status: ConversationStatus.failure));
  }

  Future<void> _onTypingStatusStartReceived(
      TypingStatusStartReceived event, Emitter<ConversationState> emit) async {
    var user = await userRepository.getUserById(event.from);
    emit(state.copyWith(
        typingStatus: TypingMessageStatus(TypingState.start, user)));
  }

  Future<void> _onTypingStatusStopReceived(
      TypingStatusStopReceived event, Emitter<ConversationState> emit) async {
    var user = await userRepository.getUserById(event.from);
    emit(state.copyWith(
        typingStatus: TypingMessageStatus(TypingState.stop, user)));
  }

  Future<void> _onReplyMessageRequired(
      ReplyMessageRequired event, Emitter<ConversationState> emit) async {
    var replyMsg = await messagesRepository.getReplyMessageById(
        currentConversation, event.replyMsgId);
    if (replyMsg == null) return;
    var messages = [...state.messages];
    var msg = messages.firstWhere((m) => m.id == event.msgId);
    var msgUpdated = msg.copyWith(replyMessage: replyMsg);
    await messagesRepository.updateMessageLocal(msgUpdated);
    messages[messages.indexOf(msg)] = msgUpdated;
    emit(state.copyWith(messages: messages));
  }

  Future<void> onMessagesMoreForReply(
      MessagesMoreForReply event, Emitter<ConversationState> emit) async {
    emit(state.copyWith(replyIdToScroll: ''));

    Future<bool> getMessagesToScroll() async {
      var canScroll = false;
      do {
        await _getAllMessages(emit,
            ltDate: state.messages.lastOrNull?.createdAt);
        canScroll =
            state.messages.firstWhereOrNull((m) => m.id == event.replyMsgId) !=
                null;
      } while (!state.hasReachedMax && !canScroll);
      return canScroll;
    }

    try {
      var result = await getMessagesToScroll().timeout(scrollToReplyTimeout);
      if (result) emit(state.copyWith(replyIdToScroll: event.replyMsgId));
    } catch (e) {
      log('[ConversationBloc][onMessagesMoreForReply]',
          stringData: e.toString());
    }
  }

  Future<void> onRemoveMessagesMoreForReply(
      RemoveMessagesMoreForReply event, Emitter<ConversationState> emit) async {
    emit(state.copyWith(replyIdToScroll: ''));
  }

  Future<void> onSelectMessagesMode(
      SelectMessagesMode event, Emitter<ConversationState> emit) async {
    final selectedMessages = Set.of(state.selectedMessages.value);
    event.choose
        ? selectedMessages.add(event.message!)
        : selectedMessages.clear();

    final allSelectedMessages = SelectedMessages.dirty(selectedMessages);
    emit(state.copyWith(
        selectedMessages: allSelectedMessages, choose: event.choose));
  }

  Future<void> onSelectedChatsAdded(
      SelectedChatsAdded event, Emitter<ConversationState> emit) async {
    var selectedMessages = Set.of(state.selectedMessages.value);
    selectedMessages.add(event.message);
    final allSelectedMessages = SelectedMessages.dirty(selectedMessages);
    if (Formz.validate([allSelectedMessages])) {
      emit(state.copyWith(selectedMessages: allSelectedMessages));
    }
  }

  Future<void> onSelectedChatsRemoved(
      SelectedChatsRemoved event, Emitter<ConversationState> emit) async {
    final selectedMessages = Set.of(state.selectedMessages.value);
    selectedMessages.remove(event.message);
    final allSelectedMessages = SelectedMessages.dirty(selectedMessages);
    emit(state.copyWith(selectedMessages: allSelectedMessages));
  }

  FutureOr<void> _onMessageReceived(
      _MessageReceived event, Emitter<ConversationState> emit) {
    var messages = [...state.messages];

    if (event.message.extension?['modified'] ?? false) {
      var indexMsg = messages.indexWhere((m) => m.id == event.message.id);
      var msg = messages[indexMsg];
      messages[indexMsg] = event.message.toChatMessage(
          msg.isLastUserMessage, msg.isFirstUserMessage, msg.bubbleType);
    } else {
      if (messages.isNotEmpty) {
        messages.first = messages.first.copyWith(
            isLastUserMessage: isServiceMessage(messages.first) ||
                event.message.from != messages.first.from,
            isFirstUserMessage: messages.length == 1 ||
                isServiceMessage(messages[1]) ||
                messages[1].from != messages.first.from,
            bubbleType:
                bubbleType(List.of(messages)..insert(0, event.message), 1));
      }

      messages.insert(
          0,
          event.message.toChatMessage(
              true,
              messages.isEmpty ||
                  isServiceMessage(messages.first) ||
                  event.message.from != messages.first.from,
              bubbleType(List.of(messages)..insert(0, event.message), 0)));
    }
    emit(state.copyWith(
        messages: messages,
        scroll: true,
        unreadMessagesCount: state.unreadMessagesCount + 1,
        status: ConversationStatus.success));
  }

  Future<void> _onPendingStatusReceived(
      _PendingStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = [...state.messages];

    var msg = messages.firstWhere((o) => o.id == event.status.messageId);
    var msgUpdated = msg.copyWith(status: MessageModelStatus.pending);
    messages[messages.indexOf(msg)] = msgUpdated;
    emit(state.copyWith(messages: messages));
  }

  Future<void> _onEditStatusReceived(
      _EditStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = [...state.messages];

    var msg = messages.firstWhere((o) => o.id == event.status.messageId);
    var msgUpdated = msg.copyWith(isEdited: true, body: event.status.newBody);
    messages[messages.indexOf(msg)] = msgUpdated;
    emit(state.copyWith(messages: messages));
  }

  Future<void> _onDeleteStatusReceived(
      _DeleteStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = [...state.messages];
    var messagesMap = {}..addEntries(messages.map((m) => MapEntry(m.id, m)));
    event.status.msgIds?.forEach((id) {
      int delMsgIndex = messages.indexOf(messagesMap[id]);
      messages.remove(messagesMap[id]);

      int prevIndex = delMsgIndex;
      int nextIndex = delMsgIndex - 1;
      ChatMessage? prevMsg = messages.tryGet(prevIndex);
      ChatMessage? nextMsg = messages.tryGet(nextIndex);

      var prevMsgUpdated = prevMsg?.copyWith(
          isLastUserMessage: prevIndex == 0 ||
              isServiceMessage(messages.tryGet(prevIndex - 1)) ||
              messages.tryGet(prevIndex - 1)?.from != messages[prevIndex].from,
          isFirstUserMessage: prevIndex == messages.length - 1 ||
              isServiceMessage(messages[prevIndex + 1]) ||
              messages[prevIndex + 1].from != messages[prevIndex].from,
          bubbleType: bubbleType(messages, prevIndex));

      var nextMsgUpdated = nextMsg?.copyWith(
          isLastUserMessage: nextIndex == 0 ||
              isServiceMessage(messages[nextIndex - 1]) ||
              messages[nextIndex - 1].from != messages[nextIndex].from,
          isFirstUserMessage: nextIndex == messages.length - 1 ||
              isServiceMessage(messages[nextIndex + 1]) ||
              messages[nextIndex + 1].from != messages[nextIndex].from,
          bubbleType: bubbleType(messages, nextIndex));

      if (prevMsgUpdated != null && prevMsgUpdated != prevMsg) {
        messages[prevIndex] = prevMsgUpdated;
      }

      if (nextMsgUpdated != null && nextMsgUpdated != nextMsg) {
        messages[nextIndex] = nextMsgUpdated;
      }
    });
    emit(state.copyWith(messages: messages));
  }

  FutureOr<void> _onSentStatusReceived(
      _SentStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = [...state.messages];

    var msg = messages.firstWhereOrNull((o) => o.id == event.status.messageId);
    if (msg == null) return;
    var msgUpdated = msg.copyWith(
        id: event.status.serverMessageId, status: MessageModelStatus.sent);

    var msgLocal = await messagesRepository.updateMessageLocal(msgUpdated);

    messages[messages.indexOf(msg)] = msgLocal.toChatMessage(
        msgUpdated.isLastUserMessage,
        msgUpdated.isFirstUserMessage,
        msgUpdated.bubbleType);
    emit(state.copyWith(messages: messages));

    var chatLocal = await conversationRepository
        .getConversationById(currentConversation.id);
    if ((chatLocal?.lastMessage?.t ?? 0) < msgLocal.t!) {
      conversationRepository.updateConversationLocal(currentConversation
          .copyWith(lastMessage: msgLocal, updatedAt: msg.createdAt));
    }
  }

  FutureOr<void> _onReadStatusReceived(
      _ReadStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = {for (var v in state.messages) v.id: v};
    var msgListUpdated = <MessageModel>[];
    event.status.msgIds?.forEach((id) {
      if (messages[id] != null &&
          messages[id]?.status != MessageModelStatus.read) {
        var msg = messages[id]!.copyWith(status: MessageModelStatus.read);
        messages[id] = msg;
        msgListUpdated.add(msg);
      }
    });
    await messagesRepository.updateMessagesLocal(msgListUpdated);
    emit(state.copyWith(messages: messages.values.toList()));
  }

  Future<void> _onFailedStatusReceived(
      _FailedStatusReceived event, Emitter<ConversationState> emit) async {
    var messages = [...state.messages];

    var msg = messages.firstWhere((o) => o.id == event.status.messageId);
    //TODO RP or set failed status
    // var msgUpdated = msg.copyWith(status: MessageModelStatus.failed);
    // messages[messages.indexOf(msg)] = msgUpdated;
    messages.remove(msg);
    emit(state.copyWith(messages: messages));
  }

  Future<List<ChatMessage>> buildChatMessageModels(
      List<MessageModel> messages) async {
    var result = <ChatMessage>[];

    var lastCurrentMsg = limitMessages == messages.length
        ? messages.tryGet(messages.length - 2)
        : messages.tryGet(messages.length - 1);

    var shouldUpdate = state.messages.isNotEmpty;

    var lastPrevMsg = state.messages.lastOrNull;
    var firstPrevMsg = state.messages.firstOrNull;

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      var chatMessage = message.toChatMessage(
          i == 0
              ? lastPrevMsg == firstPrevMsg ||
                  lastPrevMsg?.id == lastCurrentMsg?.id ||
                  lastPrevMsg?.from != messages[i].from
              : isServiceMessage(messages[i - 1]) ||
                  messages[i - 1].from != messages[i].from,
          i == messages.length - 1 ||
              isServiceMessage(messages[i + 1]) ||
              messages[i + 1].from != messages[i].from,
          i == 0 && shouldUpdate
              ? bubbleType(
                  List.of(messages)..insert(0, state.messages.last), i + 1)
              : bubbleType(messages, i));

      if (i == messages.length - 1 && limitMessages == messages.length) {
// do not put last message in result to determine bubbleType and if it's last for user with next pagination
        continue;
      }

      result.add(chatMessage);
    }
    return result;
  }

  @override
  Future<void> close() {
    unsubscribeOpponentLastActivity();
    incomingMessagesSubscription?.cancel();
    statusMessagesSubscription?.cancel();
    typingMessageSubscription?.cancel();
    lastActivitySubscription?.cancel();
    conversationWatcher?.cancel();
    headerTimer?.cancel();
    return super.close();
  }
}
