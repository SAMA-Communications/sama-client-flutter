import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import '../../api/conversations/models/models.dart';
import 'attachment_model.dart';

@Entity()
// ignore: must_be_immutable
class MessageModel extends Equatable {
  @Id()
  int? bid;
  @Unique()
  final String? id;
  final String? from;
  final String? cid;
  final String? rawStatus;
  final String? body;
  final int? t;
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
    this.id,
    this.from,
    this.cid,
    this.rawStatus,
    this.body,
    this.createdAt,
    this.t,
    this.extension,
  });

  final attachments = ToMany<AttachmentModel>();

  MessageModel copyWith({
    int? bid,
    String? id,
    String? from,
    String? cid,
    String? rawStatus,
    String? body,
    DateTime? createdAt,
    int? t,
    Map<String, dynamic>? extension,
    List<AttachmentModel>? attachments,
  }) {
    return MessageModel(
        bid: bid ?? this.bid,
        id: id ?? this.id,
        from: from ?? this.from,
        cid: cid ?? this.cid,
        rawStatus: rawStatus ?? this.rawStatus,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        t: t ?? this.t,
        extension: extension ?? this.extension)
      ..attachments.addAll(attachments ?? this.attachments);
  }

  @override
  String toString() {
    return 'MessageModel{bid: $bid, id: $id, from: $from, cid: $cid, rawStatus: $rawStatus, body: $body, t: $t, createdAt: $createdAt, extension: $extension, attachments: $attachments}';
  }

  @override
  List<Object?> get props => [
        id,
        from,
        rawStatus,
        body,
        t,
      ];
}

extension MessageModelExtension on Message {
  MessageModel toMessageModel() {
    var messageModel = MessageModel(
      id: id,
      from: from,
      cid: cid,
      rawStatus: rawStatus,
      body: body,
      createdAt: createdAt,
      t: t,
      extension: extension,
    );
    if (attachments != null) {
      messageModel.attachments.addAll(
          attachments!.map((attachment) => attachment.toAttachmentModel()));
    }
    return messageModel;
  }
}
