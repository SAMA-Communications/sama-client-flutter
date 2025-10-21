import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../api/api.dart';
import '../../../../db/models/conversation_model.dart';
import '../../../../db/models/message_model.dart';
import '../../../../repository/conversation/conversation_repository.dart';
import '../../../../repository/messages/messages_repository.dart';
import '../../models/chat_message.dart';

part 'send_message_event.dart';

part 'send_message_state.dart';

const typingThrottleDuration = 5;

EventTransformer<E> typingThrottleDroppable<E>() {
  Duration duration = const Duration(seconds: typingThrottleDuration);
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class SendMessageBloc extends Bloc<SendMessageEvent, SendMessageState> {
  final ConversationModel currentConversation;
  final ConversationRepository conversationRepository;
  final MessagesRepository messagesRepository;

  SendMessageBloc({
    required this.currentConversation,
    required this.conversationRepository,
    required this.messagesRepository,
  }) : super(const SendMessageState()) {
    on<TextMessageChanged>(
      _onTextChanged,
    );
    on<TextMessageClear>(
      _onTextMessageClear,
    );
    on<SendTextMessage>(
      _onSendTextMessage,
    );
    on<EditTextMessage>(
      _onEditTextMessage,
    );
    on<_DraftMessageReceived>(
      _onDraftMessageReceived,
    );
    on<RemoveDraftMessage>(
      _onRemoveDraftMessage,
    );
    on<AddReplyMessage>(
      _onAddSendReply,
    );
    on<RemoveReplyMessage>(
      _onRemoveSendReply,
    );
    on<AddEditMessage>(
      _onAddEditMessage,
    );
    on<RemoveEditMessage>(
      _onRemoveEditReply,
    );
    on<SendStatusReadMessages>(
      _onSendStatusReadMessages,
    );
    on<SendTypingChanged>(_onSendTypingChanged,
        transformer: typingThrottleDroppable());

    add(const _DraftMessageReceived());
  }

  Future<void> _onSendTextMessage(
      SendTextMessage event, Emitter<SendMessageState> emit) async {
    try {
      emit(state.copyWith(
          isTextEmpty: true, status: SendMessageStatus.processing));
      if (state.editMessage != null) {
        await messagesRepository.editMessage(event.message, state.editMessage);
      } else {
        await messagesRepository.sendTextMessage(
            event.message, currentConversation.id, state.replyMessage);
      }
      emit(state.copyWith(
          isTextEmpty: true, text: '', status: SendMessageStatus.success));
    } on ResponseException catch (ex) {
      emit(state.copyWith(
          errorMessage: ex.message, status: SendMessageStatus.failure));
    }
  }

  Future<void> _onEditTextMessage(
      EditTextMessage event, Emitter<SendMessageState> emit) async {
    try {
      emit(state.copyWith(
          isTextEmpty: true, status: SendMessageStatus.processing));
      var replyMessage = state.replyMessage;
      await messagesRepository.sendTextMessage(
          event.message, currentConversation.id, replyMessage);
      emit(state.copyWith(
          isTextEmpty: true, text: '', status: SendMessageStatus.success));
    } on ResponseException catch (ex) {
      emit(state.copyWith(
          errorMessage: ex.message, status: SendMessageStatus.failure));
    }
  }

  FutureOr<void> _onTextChanged(
      TextMessageChanged event, Emitter<SendMessageState> emit) {
    emit(state.copyWith(
        isTextEmpty: event.text.trim().isEmpty,
        text: event.text,
        status: SendMessageStatus.initial));
  }

  FutureOr<void> _onTextMessageClear(
      TextMessageClear event, Emitter<SendMessageState> emit) {
    emit(state.copyWith(isTextEmpty: true, text: ''));
  }

  Future<void> _onDraftMessageReceived(
      _DraftMessageReceived event, Emitter<SendMessageState> emit) async {
    var draftMsg = await messagesRepository.getMessageLocalByStatus(
        currentConversation.id, ChatMessageStatus.draft.name);
    if (draftMsg != null) {
      emit(state.copyWith(
          draftMessage: () => draftMsg,
          isTextEmpty: draftMsg.body?.trim().isEmpty,
          text: draftMsg.body,
          replyMessage: () => draftMsg.replyMessage));
      messagesRepository.deleteMessageLocal(draftMsg.id);
    }
  }

  Future<void> _onRemoveDraftMessage(
      RemoveDraftMessage event, Emitter<SendMessageState> emit) async {
    emit(state.copyWith(draftMessage: () => null));
  }

  Future<void> _onAddSendReply(
      AddReplyMessage event, Emitter<SendMessageState> emit) async {
    emit(state.copyWith(replyMessage: () => event.message));
  }

  Future<void> _onRemoveSendReply(
      RemoveReplyMessage event, Emitter<SendMessageState> emit) async {
    emit(state.copyWith(replyMessage: () => null));
  }

  Future<void> _onAddEditMessage(
      AddEditMessage event, Emitter<SendMessageState> emit) async {
    emit(state.copyWith(editMessage: () => event.message));
  }

  Future<void> _onRemoveEditReply(
      RemoveEditMessage event, Emitter<SendMessageState> emit) async {
    emit(state.copyWith(editMessage: () => null));
  }

  Future<FutureOr<void>> _onSendStatusReadMessages(
      SendStatusReadMessages event, Emitter<SendMessageState> emit) async {
    try {
      final success = await messagesRepository
          .sendStatusReadMessages(currentConversation.id);
      if (success) {
        conversationRepository.resetUnreadMessagesCount(currentConversation.id);
      }
    } catch (_) {}
  }

  Future<FutureOr<void>> _onSendTypingChanged(
      SendTypingChanged event, Emitter<SendMessageState> emit) async {
    try {
      await messagesRepository.sendTypingStatus(currentConversation.id);
    } catch (_) {}
  }

  saveDraftIfExist() {
    if (state.text.isNotEmpty) {
      messagesRepository.saveDraftMessage(
          state.text, currentConversation.id, state.replyMessage);
    }
  }

  @override
  Future<void> close() {
    saveDraftIfExist();
    return super.close();
  }
}
