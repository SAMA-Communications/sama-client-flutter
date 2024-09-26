import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'sharing_intent_event.dart';

part 'sharing_intent_state.dart';

class SharingIntentBloc extends Bloc<SharingIntentEvent, SharingIntentState> {
// TODO RP add all needed settings to iOS https://pub.dev/packages/receive_sharing_intent
  late StreamSubscription _intentSub;

  SharingIntentBloc() : super(const SharingIntentState()) {
    on<SharingIntentReceived>(
      _onSharingIntentReceived,
    );
    on<SharingIntentProcessing>(
      _onSharingIntentProcessing,
    );
    on<SharingIntentCompleted>(
      _onSharingIntentCompleted,
    );

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      if (value.isNotEmpty) {
        add(SharingIntentReceived(sharedFiles: value));
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        add(SharingIntentReceived(sharedFiles: value));
      }
      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
    });
  }

  Future<void> _onSharingIntentReceived(
      SharingIntentReceived event, Emitter<SharingIntentState> emit) async {
    return emit(state.copyWith(
      status: SharingIntentStatus.sharing,
      sharedFiles: event.sharedFiles,
    ));
  }

  Future<void> _onSharingIntentProcessing(
      SharingIntentProcessing event, Emitter<SharingIntentState> emit) async {
    return emit(state.copyWith(
      status: SharingIntentStatus.processing,
    ));
  }

  Future<void> _onSharingIntentCompleted(
      SharingIntentCompleted event, Emitter<SharingIntentState> emit) async {
    return emit(
        state.copyWith(status: SharingIntentStatus.completed, sharedFiles: []));
  }

  @override
  Future<void> close() {
    _intentSub.cancel();
    return super.close();
  }
}
