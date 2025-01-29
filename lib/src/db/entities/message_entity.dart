import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';

import 'attachment_entity.dart';

@Entity()
// ignore: must_be_immutable
class MessageEntity extends Equatable {
  @Id()
  int? id;
  @Unique()
  final String? uid;
  final String? from;
  final String? cid;
  final String? rawStatus;
  final String? body;
  final int? t;
  @Property(type: PropertyType.date)
  final DateTime? createdAt;

  // final Map<String, dynamic>? extension; //x

  MessageEntity({
    this.id,
    this.uid,
    this.from,
    this.cid,
    this.rawStatus,
    this.body,
    this.createdAt,
    this.t,
  });

  final attachments = ToMany<AttachmentEntity>();

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
