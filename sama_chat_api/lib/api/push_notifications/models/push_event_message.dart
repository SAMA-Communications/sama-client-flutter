import 'package:equatable/equatable.dart';

//TODO RP is this really need?
class PushEventMessage extends Equatable {
  final List<String>? usersIds;
  final String? title;
  final String? body;

  const PushEventMessage({
    this.usersIds,
    this.title,
    this.body,
  });

  PushEventMessage.fromJson(Map<String, dynamic> json)
      : usersIds = json['recipients_ids'],
        title = json['message']['title'],
        body = json['message']['body'];

  Map<String, dynamic> toJson() => {
        'recipients_ids': usersIds,
        'message': {'title': title, 'body': body}
      };

  @override
  List<Object?> get props => [title, body];

  static const empty = PushEventMessage();
}
