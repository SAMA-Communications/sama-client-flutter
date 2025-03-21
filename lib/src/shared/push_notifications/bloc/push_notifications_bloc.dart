import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../api/api.dart';
import '../../../db/models/conversation_model.dart';
import '../../../repository/conversation/conversation_repository.dart';

part 'push_notifications_event.dart';

part 'push_notifications_state.dart';

class PushNotificationsBloc
    extends Bloc<PushNotificationsEvent, PushNotificationsState> {
  final ConversationRepository _conversationRepository;

  PushNotificationsBloc({
    required ConversationRepository conversationRepository,
  })  : _conversationRepository = conversationRepository,
        super(const PushNotificationsState()) {
    on<PushNotificationsClicked>(
      _onPushNotificationsClicked,
    );
    on<PushNotificationsProcessing>(
      _onPushNotificationsProcessing,
    );
    on<PushNotificationsCompleted>(
      _onPushNotificationsCompleted,
    );

    _init();
  }

  _init() {
    PushNotificationsManager.instance.init();
    PushNotificationsManager.instance.onNotificationClicked = (payload) {
      print("onNotificationClicked payload= $payload");
      if (payload != null) {
        print("onNotificationClicked PushNotificationsClicked");
        add(PushNotificationsClicked(payload: payload));
      }
    };
  }

  Future<void> _onPushNotificationsClicked(PushNotificationsClicked event,
      Emitter<PushNotificationsState> emit) async {
    return emit(state.copyWith(
      status: PushNotificationsStatus.clicked,
      payload: event.payload,
    ));
  }

  Future<void> _onPushNotificationsProcessing(PushNotificationsProcessing event,
      Emitter<PushNotificationsState> emit) async {
    Map<String, dynamic> payloadObject = jsonDecode(state.payload);
    String cid = payloadObject['cid'] ?? '';
    print("[_onPushNotificationsProcessing] cid: $cid");
    var conversation = await _conversationRepository.getConversationById(cid);
    print("[_onPushNotificationsProcessing] conversation: $conversation");
    return emit(state.copyWith(
      status: PushNotificationsStatus.processing,
      conversation: conversation,
    ));
  }

  Future<void> _onPushNotificationsCompleted(PushNotificationsCompleted event,
      Emitter<PushNotificationsState> emit) async {
    return emit(state.copyWith(
      status: PushNotificationsStatus.completed,
    ));
  }
}
