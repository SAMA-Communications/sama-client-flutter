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


  @override
  String toString() {
    return 'MessageModel{id: $id, body: $body, t: $t}';
  }

  @override
  List<Object?> get props => [
        id,
        from,
        cid,
        rawStatus,
        body,
        t,
        createdAt,
        extension,
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
