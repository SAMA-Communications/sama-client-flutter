part of 'push_notifications_bloc.dart';

sealed class PushNotificationsEvent extends Equatable {
  const PushNotificationsEvent();

  @override
  List<Object> get props => [];
}

final class PushNotificationsClicked extends PushNotificationsEvent {
  const PushNotificationsClicked({required this.payload});

  final String payload;

  @override
  List<Object> get props => [payload];
}

final class PushNotificationsProcessing extends PushNotificationsEvent {}

final class PushNotificationsCompleted extends PushNotificationsEvent {}
