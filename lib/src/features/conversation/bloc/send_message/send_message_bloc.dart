import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../db/models/conversation.dart';
import '../../../../repository/messages/messages_repository.dart';

part 'send_message_event.dart';

part 'send_message_state.dart';

class SendMessageBloc extends Bloc<SendMessageEvent, SendMessageState> {
  final ConversationModel currentConversation;
  final MessagesRepository messagesRepository;

  SendMessageBloc({
    required this.currentConversation,
    required this.messagesRepository,
  }) : super(const SendMessageState()) {
    on<TextMessageChanged>(
      _onTextChanged,
    );
    on<SendTextMessage>(
      _onSendTextMessage,
    );
  }

  Future<void> _onSendTextMessage(
      SendTextMessage event, Emitter<SendMessageState> emit) async {
    try {
      await messagesRepository.sendTextMessage(
          event.message, currentConversation.id);
      emit(state.copyWith(status: SendMessageStatus.success));
    } catch (_) {
      emit(state.copyWith(status: SendMessageStatus.failure));
    }
  }

  FutureOr<void> _onTextChanged(
      TextMessageChanged event, Emitter<SendMessageState> emit) {
    emit(state.copyWith(isTextEmpty: event.text.trim().isEmpty));
  }
}
