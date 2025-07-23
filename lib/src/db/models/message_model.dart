import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import '../../api/conversations/models/models.dart';
import 'models.dart';

@Entity()
// ignore: must_be_immutable
class MessageModel extends Equatable {
  @Id()
  int? bid;
  @Unique()
  final String id;
  final String from;
  final String cid;
  final String? repliedMessageId;
  final String? rawStatus;
  final String? body;
  final bool isOwn;
  final int? t;
  final bool? isTempReplied;
  @Property(type: PropertyType.date)
  final DateTime? createdAt;
  @Transient()
  Map<String, dynamic>? extension;

  String? get dbExtension {
    return jsonEncode(extension);
  }

  set dbExtension(String? value) {
    if (value != null) extension = jsonDecode(value);
  }

  MessageModel({
    this.bid,
    required this.id,
    required this.from,
    required this.cid,
    required this.isOwn,
    this.repliedMessageId,
    this.rawStatus,
    this.body,
    this.createdAt,
    this.t,
    this.isTempReplied,
    this.extension,
  });

  final attachments = ToMany<AttachmentModel>();
  final senderBind = ToOne<UserModel>();
  final replyMessageBind = ToOne<MessageModel>();

  @Transient()
  UserModel get sender => senderBind.target ?? UserModel();

  set sender(UserModel? item) => senderBind.target = item;

  @Transient()
  MessageModel? get replyMessage => replyMessageBind.target;

  set replyMessage(MessageModel? item) => replyMessageBind.target = item;

  MessageModel copyWith({
    int? bid,
    String? id,
    String? from,
    String? cid,
    String? repliedMessageId,
    String? rawStatus,
    String? body,
    bool? isOwn,
    DateTime? createdAt,
    int? t,
    bool? isTempReplied,
    Map<String, dynamic>? extension,
    List<AttachmentModel>? attachments,
    MessageModel? replyMessage,
    UserModel? sender,
  }) {
    return MessageModel(
        bid: bid ?? this.bid,
        id: id ?? this.id,
        from: from ?? this.from,
        cid: cid ?? this.cid,
        repliedMessageId: repliedMessageId ?? this.repliedMessageId,
        rawStatus: rawStatus ?? this.rawStatus,
        body: body ?? this.body,
        isOwn: isOwn ?? this.isOwn,
        createdAt: createdAt ?? this.createdAt,
        t: t ?? this.t,
        isTempReplied: isTempReplied ?? this.isTempReplied,
        extension: extension ?? this.extension)
      ..sender = sender ?? this.sender
      ..replyMessage = replyMessage ?? this.replyMessage
      ..attachments.addAll(attachments ?? this.attachments);
  }

  @override
  String toString() {
    return 'MessageModel{bid: $bid, id: $id, from: $from, cid: $cid, rawStatus: $rawStatus, body: $body, t: $t, createdAt: $createdAt, extension: $extension, attachments: $attachments}';
  }

  @override
  List<Object?> get props => [id, from, rawStatus, body, t];
}

extension MessageModelExtension on Message {
  MessageModel toMessageModel(bool isOwn, UserModel sender) {
    var messageModel = MessageModel(
      id: id!,
      from: from!,
      cid: cid!,
      repliedMessageId: repliedMessageId,
      rawStatus: isOwn ? rawStatus ?? 'sent' : null,
      body: body,
      isOwn: isOwn,
      createdAt: createdAt,
      t: t,
      extension: extension,
    )..sender = sender;

    if (attachments != null) {
      messageModel.attachments.addAll(
          attachments!.map((attachment) => attachment.toAttachmentModel()));
    }
    return messageModel;
  }
}
