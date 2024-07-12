import 'package:sama_client_flutter/src/api/chats/realtime/models/message_statuses.dart';
import 'package:sama_client_flutter/src/api/connection/connection.dart';

import '../conversations/models/models.dart';

const String messageEditRequestName = 'message_edit';
const String messagesListRequestName = 'message_list';
const String messagesReadRequestName = 'message_read';
const String messagesDeleteRequestName = 'message_delete';

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
      .sendRequest(messagesReadRequestName, deleteMessagesStatus.toJson())
      .then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}
