import 'package:equatable/equatable.dart';
import 'package:sqflite/sqflite.dart';

import '../../api/api.dart';

//FixME RP later
class ConversationFields {
  static const String tableName = 'conversations';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String opponentId = 'opponent_id';
  static const String ownerId = 'owner_id';
  static const String type = 'type';
  static const int unreadMessagesCount = 0;
  static const Message lastMessage = Message.empty; //last_message
  static const List<String> participantsIds = []; //last_message
  static const Avatar avatar = Avatar.empty; //last_message
}

class ConversationModel extends Equatable {
  final String id;
  final DateTime createdAt; //created_at
  final DateTime updatedAt; //updated_at
  final String type;
  final String name;
  final String? description;
  final int? unreadMessagesCount;
  final Message? lastMessage;
  final User? opponent;
  final User? owner;
  final Avatar? avatar;

  const ConversationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.type,
    required this.unreadMessagesCount,
    required this.lastMessage,
    required this.opponent,
    required this.owner,
    this.description,
    this.avatar,
  });

  ConversationModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    String? name,
    String? description,
    int? unreadMessagesCount,
    Message? lastMessage,
    User? opponent,
    User? owner,
    Avatar? avatar,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      lastMessage: lastMessage ?? this.lastMessage,
      opponent: opponent ?? this.opponent,
      owner: owner ?? this.owner,
      avatar: avatar ?? this.avatar,
    );
  }

  ConversationModel copyWithItem({
    required ConversationModel item,
  }) {
    return copyWith(
      updatedAt: updatedAt != item.updatedAt ? item.updatedAt : updatedAt,
      name: name != item.name ? item.name : name,
      unreadMessagesCount: unreadMessagesCount != item.unreadMessagesCount
          ? item.unreadMessagesCount
          : unreadMessagesCount,
      description:
          description != item.description ? item.description : description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        unreadMessagesCount,
        description,
        lastMessage,
      ];
}
