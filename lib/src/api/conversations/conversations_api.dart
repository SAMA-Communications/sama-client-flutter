import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../api.dart';

const String conversationsRequest = 'conversation_list';
const String getParticipantsByCids = 'get_participants_by_cids';
const String conversationSearch = 'conversation_search';
const String conversationCreate = 'conversation_create';
const String conversationDelete = 'conversation_delete';

Future<List<Conversation>> fetchConversations([int startIndex = 0]) async {
  return SamaConnectionService.instance
      .sendRequest(conversationsRequest, {}).then((response) {
    List<Conversation> conversations;
    List<dynamic> items = List.of(response['conversations']);
    if (items.isEmpty) {
      conversations = [];
    } else {
      conversations =
          items.map((element) => Conversation.fromJson(element)).toList();
    }
    return conversations;
  });
}

Future<List<User>> fetchParticipants(List<String> cids) async {
  return SamaConnectionService.instance.sendRequest(getParticipantsByCids, {
    'cids': cids,
  }).then((response) {
    List<User> users;
    List<dynamic> items = List.of(response['users']);
    if (items.isEmpty) {
      users = [];
    } else {
      users = items.map((element) => User.fromJson(element)).toList();
    }
    return users;
  });
}

Future<List<String>> searchConversationsIdsByName(String name) async {
  return SamaConnectionService.instance.sendRequest(conversationSearch, {
    'name': name,
    'limit': 10,
  }).then((response) {
    return List.of(response['conversations']).cast<String>();
  });
}

Future<Conversation> createConversation(List<String> participants, String type,
    String? name, Avatar? avatar) async {
  return SamaConnectionService.instance.sendRequest(conversationCreate, {
    if (name != null) 'name': name,
    'type': type,
    'participants': participants,
    if (avatar != null) 'image_object': avatar.toImageObjectJson(),
  }).then((response) {
    return Conversation.fromJson(response['conversation']);
  });
}

Future<bool> deleteConversation(String id) async {
  return SamaConnectionService.instance
      .sendRequest(conversationDelete, {"id": id}).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<String> uploadAvatarFile(File file) async {
  List<Map<String, dynamic>> requestData = [
    {
      'name': basename(file.path),
      'size': file.lengthSync(),
      'content_type': lookupMimeType(file.path),
    }
  ];
  var responseFile = await SamaConnectionService.instance
      .sendRequest(createFilesRequestName, jsonDecode(jsonEncode(requestData)));
  var rawFiles = List.of(responseFile['files'])
      .map((rawFile) => Map<String, dynamic>.of(rawFile))
      .toList();

  final rawFile = rawFiles.first;

  var uri = Uri.tryParse(rawFile['upload_url']);

  var fileId = rawFile['object_id'];
  var contentType = rawFile['content_type'];
  var contentLength = rawFile['size'];

  if (uri != null) {
    ByteStream stream = ByteStream(file.openRead());

    Map<String, String> headers = {
      'Content-Length': contentLength.toString(),
      'Content-Type': contentType,
    };

    var request = StreamedRequest(
      'PUT',
      uri,
    )
      ..headers.addAll(headers)
      ..contentLength = contentLength;

    request.sink.addStream(stream).then((_) async {
      await request.sink.close();
    });
    await request.send();
  }
  return fileId;
}
