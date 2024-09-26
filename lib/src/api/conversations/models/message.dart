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
  final DateTime? createdAt; //created_at
  final Map<String, dynamic>? extension; //x

  const Message({
    this.id,
    this.from,
    this.cid,
    this.status,
    this.body,
    this.attachments,
    this.createdAt,
    this.t,
    this.extension,
  });

  Message.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        from = json['from'],
        cid = json['cid'],
        status = json['status'],
        body = json['body'],
        attachments = json['attachments'] == null
            ? null
            : List.of(json['attachments'])
                .map((element) => Attachment.fromJson(element))
                .toList(),
        createdAt = DateTime.tryParse(json['created_at'].toString()),
        t = json['t'],
        extension = json['x'];

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
        id, status, attachments, body
      ];

  static const empty = Message();
}
