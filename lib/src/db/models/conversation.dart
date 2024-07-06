import 'package:sqflite/sqflite.dart';

import '../../api/api.dart';
import '../../api/conversations/models/message.dart';

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
}

class ConversationModel {
  final String id;
  final DateTime createdAt; //created_at
  final DateTime updatedAt; //updated_at
  final String type;
  final String? name;
  final int? unreadMessagesCount;
  final Message? lastMessage;
  final User? opponent;

  ConversationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.type,
    required this.unreadMessagesCount,
    required this.lastMessage,
    required this.opponent,
  });
}
