import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../api.dart';

const stopTypingTime = 6;

enum TypingState { start, stop }

class TypingStatus extends Equatable {
  final TypingState state;
  final String? cid;
  final String? from;

  const TypingStatus(this.state, this.cid, this.from);

  TypingStatus copyWith({
    TypingState? state,
    String? cid,
    String? from,
  }) {
    return TypingStatus(
      state ?? this.state,
      cid ?? this.cid,
      from ?? this.from,
    );
  }

  @override
  List<Object?> get props => [state, cid, from];
}

class TypingManager {
  TypingManager._() {
    _init();
  }

  static final _instance = TypingManager._();

  static TypingManager get instance {
    return _instance;
  }

  Map<String, Timer> clearTypingTimers = {};
  StreamSubscription<TypingMessageStatus>? typingMessageSubscription;

  final StreamController<TypingStatus> _typingStatusController =
      StreamController.broadcast();

  Stream<TypingStatus> get typingStatusStream => _typingStatusController.stream;

  _init() {
    typingMessageSubscription = MessagesManager.instance.typingStatusStream
        .listen((typingStatus) async {
      var typing =
          TypingStatus(TypingState.start, typingStatus.cid, typingStatus.from);
      _typingStatusController.add(typing);

      restartTypingTimer(typingStatus.cid ?? '', () {
        _typingStatusController.add(typing.copyWith(state: TypingState.stop));
      });
    });
  }

  void restartTypingTimer(String cid, void Function() callback) {
    clearTypingTimers[cid]?.cancel();
    var timer = Timer(const Duration(seconds: stopTypingTime), callback);
    clearTypingTimers[cid] = timer;
  }

  destroy() {
    typingMessageSubscription?.cancel();
    clearTypingTimers.clear();
  }
}
