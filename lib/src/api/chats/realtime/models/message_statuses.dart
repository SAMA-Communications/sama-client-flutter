abstract class MessageStatus {
  String cid;
  List<String>? msgIds;
  String? from;

  MessageStatus.fromJson(Map<String, dynamic> json)
      : cid = json['cid'],
        msgIds = json['ids']?.cast<String>(),
        from = json['from'];

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      if (msgIds != null) 'ids': msgIds,
      if (from != null) 'from': from,
    };
  }
}

sealed class MessageSendStatus {}

class PendingMessageStatus implements MessageSendStatus {
  final String messageId;

  PendingMessageStatus.fromJson(Map<String, dynamic> json)
      : messageId = json['mid'];

  Map<String, dynamic> toJson() {
    return {'mid': messageId};
  }
}

class SentMessageStatus implements MessageSendStatus {
  final String messageId; // mid
  final String serverMessageId; // server_mid
  final int time; // t

  SentMessageStatus.fromJson(Map<String, dynamic> json)
      : messageId = json['mid'],
        serverMessageId = json['server_mid'],
        time = json['t'];
}

class ReadMessagesStatus extends MessageStatus implements MessageSendStatus {
  ReadMessagesStatus.fromJson(super.json) : super.fromJson();
}

class FailedMessagesStatus implements MessageSendStatus {
  final String messageId;

  FailedMessagesStatus.fromJson(Map<String, dynamic> json)
      : messageId = json['mid'];
}

class EditMessageStatus implements MessageSendStatus {
  final String messageId; // id
  final String newBody; // body
  final String from; // body

  EditMessageStatus(this.messageId, this.newBody, this.from);

  EditMessageStatus.fromJson(Map<String, dynamic> json)
      : messageId = json['id'],
        newBody = json['body'],
        from = json['from'];

  Map<String, dynamic> toJson() =>
      {'id': messageId, 'body': newBody, 'from': from};
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

class TypingMessageStatus {
  final String? cid; // cid
  final String? type; // c_type
  final String? from; // from
  final int? t; // t

  TypingMessageStatus.fromJson(Map<String, dynamic> json)
      : cid = json['cid'],
        type = json['c_type'],
        from = json['from'],
        t = json['t'];

  Map<String, dynamic> toJson() => {'cid': cid};
}
