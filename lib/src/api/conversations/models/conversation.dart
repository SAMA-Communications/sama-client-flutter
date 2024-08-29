import 'package:equatable/equatable.dart';

import 'avatar.dart';
import 'message.dart';

class Conversation extends Equatable {
  final String? id; //_id
  final DateTime? createdAt; //created_at
  final DateTime? updatedAt; //updated_at
  final Message? lastMessage; //last_message
  final String? opponentId; //opponent_id
  final String? ownerId; //owner_id
  final String? type; //type 'u', 'g'
  final String? name; //name
  final String? description; //description
  final int? unreadMessagesCount; //unread_messages_count
  final Avatar? avatar; //unread_messages_count

  const Conversation(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.lastMessage,
      this.opponentId,
      this.ownerId,
      this.type,
      this.name,
      this.description,
      this.unreadMessagesCount,
      this.avatar});

  Conversation.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        createdAt = DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        lastMessage = json['last_message'] != null
            ? Message.fromJson(json['last_message'])
            : null,
        opponentId = json['opponent_id'],
        ownerId = json['owner_id'],
        type = json['type'],
        name = json['name'],
        description = json['description'],
        unreadMessagesCount = json['unread_messages_count'],
        avatar = Avatar.fromJson(json);

  Map<String, dynamic> toJson() => {
        '_id': id,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'opponent_id': opponentId,
        'owner_id': ownerId,
        'type': type,
        'name': name,
        'description': description,
        'unread_messages_count': unreadMessagesCount,
        'image_object': avatar?.toImageObjectJson(),
      };

  @override
  List<Object?> get props => [
        id,
      ];

  static const empty = Conversation();
}
