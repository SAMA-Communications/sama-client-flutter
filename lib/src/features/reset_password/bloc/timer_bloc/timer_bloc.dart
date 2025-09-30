import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../ticker.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(const TimerInitial(0)) {
    on<TimerStarted>(_onStarted);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);
  }

  final Ticker _ticker;
  static const int _duration = 90;

  StreamSubscription<int>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(const TimerRunInProgress(_duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: _duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : const TimerRunComplete(),
    );
  }
}
