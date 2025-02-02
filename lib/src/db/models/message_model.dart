import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import 'attachment_model.dart';

@Entity()
// ignore: must_be_immutable
class MessageModel extends Equatable {
  @Id()
  int? bid;
  @Unique(onConflict: ConflictStrategy.replace)
  final String? id;
  final String? from;
  final String? cid;
  final String? rawStatus;
  final String? body;
  final int? t;
  @Property(type: PropertyType.date)
  final DateTime? createdAt;

  // final Map<String, dynamic>? extension; //x

  MessageModel({
    this.bid,
    this.id,
    this.from,
    this.cid,
    this.rawStatus,
    this.body,
    this.createdAt,
    this.t,
  });

  final attachments = ToMany<AttachmentModel>();

  @override
  String toString() {
    return 'MessageModel{bid: $bid, id: $id}';
  } // List<AttachmentModel>? get attachments => attachmentsBind;
  // set attachments(List<AttachmentModel>? item) => attachmentsBind = item;

  @override
  List<Object?> get props => [
        id,
        from,
        cid,
        rawStatus,
        body,
        t,
        createdAt,
      ];
}
