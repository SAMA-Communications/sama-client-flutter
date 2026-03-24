import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';
import 'package:sama_sdk/api/conversations/models/message.dart';

import 'models.dart';

enum MessageModelStatus { none, pending, draft, sent, read }

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
  final String? forwardedMessageId;
  @Transient()
  MessageModelStatus status;
  final String? body;
  final bool isOwn;
  final int? t;
  final bool? isTempReplied;
  final bool? isEdited;
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

  int? get dbStatus {
    ensureStableEnumValues();
    return status.index;
  }

  set dbStatus(int? value) {
    ensureStableEnumValues();
    if (value == null) {
      status = MessageModelStatus.none;
    } else {
      status = value >= 0 && value < MessageModelStatus.values.length
          ? MessageModelStatus.values[value]
          : MessageModelStatus.none;
    }
  }

  void ensureStableEnumValues() {
    assert(MessageModelStatus.none.index == 0);
    assert(MessageModelStatus.pending.index == 1);
    assert(MessageModelStatus.draft.index == 2);
    assert(MessageModelStatus.sent.index == 3);
    assert(MessageModelStatus.read.index == 4);
  }

  MessageModel({
    this.bid,
    required this.id,
    required this.from,
    required this.cid,
    required this.isOwn,
    this.repliedMessageId,
    this.forwardedMessageId,
    this.status = MessageModelStatus.none,
    this.body,
    this.createdAt,
    this.t,
    this.isTempReplied,
    this.isEdited,
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
    String? forwardedMessageId,
    MessageModelStatus? status,
    String? body,
    bool? isOwn,
    DateTime? createdAt,
    int? t,
    bool? isTempReplied,
    bool? isEdited,
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
        forwardedMessageId: forwardedMessageId ?? this.forwardedMessageId,
        status: status ?? this.status,
        body: body ?? this.body,
        isOwn: isOwn ?? this.isOwn,
        createdAt: createdAt ?? this.createdAt,
        t: t ?? this.t,
        isTempReplied: isTempReplied ?? this.isTempReplied,
        isEdited: isEdited ?? this.isEdited,
        extension: extension ?? this.extension)
      ..sender = sender ?? this.sender
      ..replyMessage = replyMessage ?? this.replyMessage
      ..attachments.addAll(attachments ?? this.attachments);
  }

  @override
  String toString() {
    return 'MessageModel{bid: $bid, id: $id, from: $from, cid: $cid, status: $status, body: $body, t: $t, createdAt: $createdAt, extension: $extension, attachments: $attachments}';
  }

  @override
  List<Object?> get props =>
      [id, from, status, body, t, createdAt?.millisecondsSinceEpoch];
}

extension MessageModelExtension on Message {
  MessageModel toMessageModel(bool isOwn, UserModel sender) {
    var messageModel = MessageModel(
      id: id!,
      from: from!,
      cid: cid!,
      repliedMessageId: repliedMessageId,
      forwardedMessageId: forwardedMessageId,
      status: isOwn
          ? MessageModelStatus.values
                  .firstWhereOrNull((i) => i.name == rawStatus) ??
              MessageModelStatus.sent
          : MessageModelStatus.none,
      body: body,
      isOwn: isOwn,
      createdAt: createdAt,
      t: t,
      extension: extension,
      isEdited: (createdAt?.millisecond ?? 0) < (updatedAt?.millisecond ?? 0),
    )..sender = sender;

    if (attachments != null) {
      messageModel.attachments.addAll(
          attachments!.map((attachment) => attachment.toAttachmentModel()));
    }
    return messageModel;
  }
}
