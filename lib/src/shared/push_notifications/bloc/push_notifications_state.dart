part of 'push_notifications_bloc.dart';

enum PushNotificationsStatus {
  initial,
  clicked,
  processing,
  completed,
}

final class PushNotificationsState extends Equatable {
  const PushNotificationsState(
      {this.status = PushNotificationsStatus.initial,
      this.payload = '',
      this.conversation});

  final PushNotificationsStatus status;
  final String payload;
  final ConversationModel? conversation;

  PushNotificationsState copyWith({
    PushNotificationsStatus? status,
    String? payload,
    ConversationModel? conversation,
  }) {
    return PushNotificationsState(
      status: status ?? this.status,
      payload: payload ?? this.payload,
      conversation: conversation ?? this.conversation,
    );
  }

  @override
  List<Object?> get props => [status, payload, conversation];
}
