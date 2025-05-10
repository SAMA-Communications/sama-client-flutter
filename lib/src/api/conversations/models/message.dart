import 'package:equatable/equatable.dart';

import 'attachment.dart';

class Message extends Equatable {
  final String? id; //_id
  final String? from; //from
  final String? cid; //cid
  final String? rawStatus; //status
  final String? body; //body
  final List<Attachment>? attachments; //attachments
  final int? t; //t
  final DateTime? createdAt; //created_at
  final Map<String, dynamic>? extension; //x

  const Message({
    this.id,
    this.from,
    this.cid,
    this.rawStatus,
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
        rawStatus = json['status'],
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
        'status': rawStatus,
        'body': body,
        't': createdAt,
      };

  Message copyWith({
    String? id,
    String? from,
    String? cid,
    String? rawStatus,
    String? body,
    List<Attachment>? attachments,
    int? t,
    DateTime? createdAt,
    Map<String, dynamic>? extension,
  }) {
    return Message(
      id: id ?? this.id,
      from: from ?? this.from,
      cid: cid ?? this.cid,
      rawStatus: rawStatus ?? this.rawStatus,
      body: body ?? this.body,
      attachments: attachments ?? this.attachments,
      t: t ?? this.t,
      createdAt: createdAt ?? this.createdAt,
      extension: extension ?? this.extension,
    );
  }

  @override
  List<Object?> get props => [id, rawStatus, attachments, body];

  static const empty = Message();
}
