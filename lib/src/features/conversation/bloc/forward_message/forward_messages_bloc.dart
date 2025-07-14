import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../db/models/conversation_model.dart';
import '../../../../repository/conversation/conversation_repository.dart';
import '../../../../repository/messages/messages_repository.dart';
import '../../models/chat_message.dart';

part 'forward_messages_event.dart';

part 'forward_messages_state.dart';

class ForwardMessagesBloc
    extends Bloc<ForwardMessagesEvent, ForwardMessagesState> {
  final ConversationRepository conversationRepository;
  final MessagesRepository messagesRepository;

  ForwardMessagesBloc({
    required this.conversationRepository,
    required this.messagesRepository,
  }) : super(const ForwardMessagesState()) {
    on<ChatsToForward>(
      _onChatsToForward,
    );
    on<SendForwardMessage>(
      _onSendForwardMessage,
    );

    add(const ChatsToForward());
  }

  Future<void> _onChatsToForward(
      ChatsToForward event, Emitter<ForwardMessagesState> emit) async {
    try {
      final chats = await conversationRepository.getStoredConversations();
      emit(state.copyWith(chats: chats));
    } catch (_) {
      emit(state.copyWith(
          status: ForwardMessagesStatus.failure,
          errorMessage: 'Some error occurred'));
    }
  }

  Future<void> _onSendForwardMessage(
      SendForwardMessage event, Emitter<ForwardMessagesState> emit) async {
    var chatTo = event.forwardChatsTo;
    var forwardMessages = event.forwardMessages;
    await messagesRepository
        .sendForwardMessages(chatTo.first, forwardMessages)
        .catchError((e) {
      emit(state.copyWith(
          status: ForwardMessagesStatus.failure,
          errorMessage: 'Forward failed'));
    });
    emit(state.copyWith(status: ForwardMessagesStatus.success));
  }
}
