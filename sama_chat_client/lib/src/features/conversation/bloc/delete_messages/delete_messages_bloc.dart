import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api/api.dart';
import '../../../../db/models/conversation_model.dart';
import '../../../../repository/messages/messages_repository.dart';
import '../../models/chat_message.dart';

part 'delete_messages_event.dart';

part 'delete_messages_state.dart';

class DeleteMessagesBloc
    extends Bloc<DeleteMessagesEvent, DeleteMessagesState> {
  final MessagesRepository messagesRepository;

  DeleteMessagesBloc({
    required this.messagesRepository,
  }) : super(const DeleteMessagesState()) {
    on<DeleteMessages>(
      _onDeleteMessages,
    );
  }

  Future<void> _onDeleteMessages(
      DeleteMessages event, Emitter<DeleteMessagesState> emit) async {
    var msgIdsToDelete = event.messages.map((m) => m.id).toList();
    var cid = event.messages.first.cid;
    emit(state.copyWith(status: DeleteMessagesStatus.processing));
    await messagesRepository
        .deleteMessage(cid, msgIdsToDelete, event.type)
        .catchError((e) {
      emit(state.copyWith(
          status: DeleteMessagesStatus.failure, errorMessage: 'Delete failed'));
    });

    emit(state.copyWith(status: DeleteMessagesStatus.success));
  }
}
