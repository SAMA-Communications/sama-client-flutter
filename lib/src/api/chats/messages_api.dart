import '../connection/connection.dart';
import '../conversations/models/models.dart';
import 'realtime/models/models.dart';

const String messageRequestName = 'message';
const String messageEditRequestName = 'message_edit';
const String messagesListRequestName = 'message_list';
const String messagesReadRequestName = 'message_read';
const String messagesDeleteRequestName = 'message_delete';

const messageRequestTimeout = Duration(seconds: 5);

Future<bool> sendMessage({
  required Message message,
}) {
  var dataToSend = {
    'id': message.id,
    'cid': message.cid,
    if (message.body?.isNotEmpty ?? false) 'body': message.body,
    if (message.extension != null) 'x': message.extension,
    if (message.attachments != null) 'attachments': message.attachments,
  };

  return SamaConnectionService.instance
      .sendRequest(messageRequestName, dataToSend, retryRequestId: message.id)
      .timeout(messageRequestTimeout)
      .then((response) {
    if (message.id == response['mid']) {
      return true;
    }
    return false;
  }).catchError((onError) {
    return false;
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
