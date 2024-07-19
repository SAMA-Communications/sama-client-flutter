abstract class MessageStatus {
  String cid;
  List<String> msgIds;
  String? from;

  MessageStatus.fromJson(Map<String, dynamic> json)
      : cid = json['cid'],
        msgIds = List<String>.from(json['ids']),
        from = json['from'];

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'ids': msgIds,
      if (from != null) 'from': from,
    };
  }
}

class SentMessageStatus {
  final String messageId; // mid
  final String serverMessageId; // server_mid
  final DateTime time; // t

  SentMessageStatus.fromJson(Map<String, dynamic> json)
      : messageId = json['mid'],
        serverMessageId = json['server_mid'],
        time = DateTime.parse(json['t'].toString());
}

class ReadMessagesStatus extends MessageStatus {
  ReadMessagesStatus.fromJson(super.json) : super.fromJson();
}

class EditMessageStatus {
  final String messageId; // id
  final String newBody; // body
  final String? from;

  EditMessageStatus(this.messageId, this.newBody, this.from);

  EditMessageStatus.fromJson(Map<String, dynamic> json)
      : messageId = json['id'],
        newBody = json['body'],
        from = json['from'];

  Map<String, dynamic> toJson() => {
        'id': messageId,
        'body': newBody,
        if (from != null) 'from': from,
      };
}

class DeleteMessagesStatus extends MessageStatus {
  DeleteMessageType deletingType; // type

  DeleteMessagesStatus.fromJson(super.json)
      : deletingType = DeleteMessageType.values.asNameMap()[json['type']]!,
        super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'type': deletingType.name,
    };
  }
}

enum DeleteMessageType { myself, all }
