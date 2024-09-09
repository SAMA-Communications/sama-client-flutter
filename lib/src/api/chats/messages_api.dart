import 'dart:convert';

import '../connection/connection.dart';
import '../conversations/models/models.dart';
import '../utils/logger.dart';
import 'realtime/models/models.dart';

const String messageEditRequestName = 'message_edit';
const String messagesListRequestName = 'message_list';
const String messagesReadRequestName = 'message_read';
const String messagesDeleteRequestName = 'message_delete';

Future<void> sendMessage({
  required Message message,
}) {
  return SamaConnectionService.instance.getConnection().then((connection) {
    var dataToSend = {
      'message': {
        'id': message.id,
        'cid': message.cid,
        'body': message.body,
        if (message.extension != null) 'x': message.extension,
        if (message.attachments != null) 'attachments': message.attachments,
      },
    };

    log('[MessagesManager][sendMessage]', jsonData: dataToSend);
    connection.sink.add(jsonEncode(dataToSend));
  });
}

Future<bool> editMessage(EditMessageStatus editMessageStatus) {
  return SamaConnectionService.instance
      .sendRequest(messageEditRequestName, editMessageStatus.toJson())
      .then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<List<Message>> getMessages(Map<String, dynamic> params) {
  return SamaConnectionService.instance
      .sendRequest(messagesListRequestName, params)
      .then((response) {
    return List.from(response['messages'])
        .map((element) => Message.fromJson(element))
        .toList();
  });
}

Future<bool> readMessages(ReadMessagesStatus readMessageStatus) {
  return SamaConnectionService.instance
      .sendRequest(messagesReadRequestName, readMessageStatus.toJson())
      .then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<bool> deleteMessages(DeleteMessagesStatus deleteMessagesStatus) {
  return SamaConnectionService.instance
      .sendRequest(messagesDeleteRequestName, deleteMessagesStatus.toJson())
      .then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}
