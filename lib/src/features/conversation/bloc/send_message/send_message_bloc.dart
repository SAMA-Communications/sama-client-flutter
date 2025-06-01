import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../api/api.dart';
import '../../../../db/models/conversation_model.dart';
import '../../../../repository/conversation/conversation_repository.dart';
import '../../../../repository/messages/messages_repository.dart';

part 'send_message_event.dart';

part 'send_message_state.dart';

EventTransformer<E> typingThrottleDroppable<E>() {
  Duration duration = const Duration(seconds: 5);
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
    on<SendStatusReadMessages>(
      _onSendStatusReadMessages,
    );
    on<SendTypingChanged>(_onSendTypingChanged,
        transformer: typingThrottleDroppable());
  }

  Future<void> _onSendTextMessage(
      SendTextMessage event, Emitter<SendMessageState> emit) async {
    try {
      emit(state.copyWith(
          isTextEmpty: true, status: SendMessageStatus.processing));
      await messagesRepository.sendTextMessage(
          event.message, currentConversation.id);
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
      messagesRepository.saveDraftMessage(state.text, currentConversation.id);
    }
  }

  @override
  Future<void> close() {
    saveDraftIfExist();
    return super.close();
  }
}
