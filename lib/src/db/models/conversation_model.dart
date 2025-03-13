import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import '../../db/models/user_model.dart';
import 'avatar_model.dart';
import 'message_model.dart';

@Entity()
// ignore: must_be_immutable
class ConversationModel extends Equatable {
  @Id()
  int? bid;
  @Unique()
  final String id;
  @Property(type: PropertyType.date)
  final DateTime createdAt;
  @Property(type: PropertyType.date)
  final DateTime updatedAt;
  final String type;
  final String name;
  final String? description;
  final int? unreadMessagesCount;
  final bool? isEncrypted;

  ConversationModel({
    this.bid,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.type,
    this.unreadMessagesCount,
    this.description,
    this.isEncrypted,
  });

  final lastMessageBind = ToOne<MessageModel>();
  final opponentBind = ToOne<UserModel>();
  final ownerBind = ToOne<UserModel>();
  final participants = ToMany<UserModel>();
  final avatarBind = ToOne<AvatarModel>();

  @Transient()
  MessageModel? get lastMessage => lastMessageBind.target;

  @Transient()
  UserModel? get opponent => opponentBind.target;

  @Transient()
  UserModel? get owner => ownerBind.target;

  @Transient()
  AvatarModel? get avatar => avatarBind.target;

  set lastMessage(MessageModel? item) => lastMessageBind.target = item;

  set opponent(UserModel? item) => opponentBind.target = item;

  set owner(UserModel? item) => ownerBind.target = item;

  set avatar(AvatarModel? item) => avatarBind.target = item;

  ConversationModel copyWith({
    int? bid,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    String? name,
    bool? isEncrypted,
    String? description,
    int? unreadMessagesCount,
    MessageModel? lastMessage,
    UserModel? opponent,
    UserModel? owner,
    List<UserModel>? participants,
    AvatarModel? avatar,
  }) {
    var chat = ConversationModel(
        bid: bid ?? this.bid,
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
        isEncrypted: isEncrypted ?? this.isEncrypted)
      ..lastMessage = lastMessage ?? this.lastMessage
      ..opponent = opponent ?? this.opponent
      ..owner = owner ?? this.owner
      ..avatar = avatar ?? this.avatar;
    if (participants != null) {
      if (this.participants.isNotEmpty) {
        this.participants.clear();
        this.participants.applyToDb();
      }
      chat.participants.addAll(participants);
    }

    return chat;
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
      lastMessage:
          lastMessage != item.lastMessage ? item.lastMessage : lastMessage,
      avatar: avatar != item.avatar ? item.avatar : avatar,
      participants:
          participants != item.participants ? item.participants : participants,
    );
  }

  @override
  String toString() {
    return 'ConversationModel{bid: $bid, id: $id, lastMessage: $lastMessage}';
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
        isEncrypted,
        lastMessage,
        opponent,
        owner,
        avatar,
        participants
      ];
}
