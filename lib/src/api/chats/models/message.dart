import 'package:equatable/equatable.dart';

import 'attachment.dart';

class Message extends Equatable {
  final String? id; //_id
  final String? from; //from
  final String? cid; //cid
  final String? status; //status
  final String? body; //body
  final List<Attachment>? attachments; //attachments
  final int? t; //t
  final int? createdAt; //created_at

  const Message({
    this.id,
    this.from,
    this.cid,
    this.status,
    this.body,
    this.attachments,
    this.createdAt,
    this.t,
  });

  Message.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        from = json['opponent_id'],
        cid = json['cid'],
        status = json['status'],
        body = json['body'],
        attachments = json['attachments'] == null ? null : List.of(json['attachments']).map((element) => Attachment.fromJson(element)).toList(),
        createdAt = json['created_at'],
        t = json['t'];


  Map<String, dynamic> toJson() => {
    '_id': id,
    'from': from,
    'cid': cid,
    'status': status,
    'body': body,
    't': createdAt,
  };

  @override
  List<Object?> get props => [
    id,
  ];

  static const empty = Message();
}
