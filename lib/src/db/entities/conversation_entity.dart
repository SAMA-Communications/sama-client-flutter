import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';
import 'package:sama_client_flutter/src/db/entities/user_entity.dart';

import 'avatar_entity.dart';
import 'message_entity.dart';

@Entity()
// ignore: must_be_immutable
class ConversationEntity extends Equatable {
  @Id()
  int? id;
  @Unique()
  final String? uid;
  @Property(type: PropertyType.date)
  final DateTime? createdAt;
  @Property(type: PropertyType.date)
  final DateTime? updatedAt;
  final String? type;
  final String? name;
  final String? description;
  final int? unreadMessagesCount;

  ConversationEntity({
    this.id,
    this.uid,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.type,
    this.unreadMessagesCount,
    this.description,
  });

  final lastMessage = ToOne<MessageEntity>();
  final opponent = ToOne<UserEntity>();
  final owner = ToOne<UserEntity>();
  final avatar = ToOne<AvatarEntity>();

  ConversationEntity copyWith({
    String? uid,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    String? name,
    String? description,
    int? unreadMessagesCount,
    MessageEntity? lastMessage,
    UserEntity? opponent,
    UserEntity? owner,
    AvatarEntity? avatar,
  }) {
    return ConversationEntity(
        uid: uid ?? this.uid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount)
      ..lastMessage.target = lastMessage ?? this.lastMessage.target
      ..opponent.target = opponent ?? this.opponent.target
      ..owner.target = owner ?? this.owner.target
      ..avatar.target = avatar ?? this.avatar.target;
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        type,
        name,
        description,
        unreadMessagesCount,
        lastMessage,
        opponent,
        owner,
        avatar,
      ];
}
