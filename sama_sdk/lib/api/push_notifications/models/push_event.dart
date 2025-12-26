import 'package:equatable/equatable.dart';

class PushEvent extends Equatable {
  final String? id; //_id
  final DateTime? createdAt; //created_at
  final DateTime? updatedAt; //updated_at
  final String? userId; //user_id
  final List<String>? recipientsIds; //recipients_ids
  final String? title; //message
  final String? body; //message

  const PushEvent({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.recipientsIds,
    this.title,
    this.body,
  });

  PushEvent.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        createdAt = DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        userId = json['user_id'],
        recipientsIds = json['recipients_ids'],
        title = json['message']['title'],
        body = json['message']['body'];

  Map<String, dynamic> toJson() => {
        '_id': id,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'user_id': userId,
        'recipients_ids': recipientsIds,
        'title': title,
        'body': body,
      };

  @override
  List<Object?> get props => [
        id,
      ];

  static const empty = PushEvent();
}
