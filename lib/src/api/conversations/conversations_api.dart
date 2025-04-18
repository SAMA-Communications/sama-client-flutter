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
const String conversationUpdate = 'conversation_update';
const String conversationDelete = 'conversation_delete';

Future<List<Conversation>> fetchConversations(
    Map<String, dynamic>? params) async {
  return SamaConnectionService.instance
      .sendRequest(conversationsRequest, params)
      .then((response) {
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

Future<(Map<String, List<String>>, List<User>)> fetchParticipants(
    List<String> cids) async {
  return SamaConnectionService.instance.sendRequest(getParticipantsByCids, {
    'cids': cids,
  }).then((response) {
    List<User> users = List.of(response['users'])
        .map((element) => User.fromJson(element))
        .toList();

    Map<String, List<String>> participants = Map.of(response['conversations'])
        .map((k, v) => MapEntry(k, v.cast<String>()));
    return (participants, users);
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

Future<List<Conversation>> fetchConversationsByIds(List<String> cids) async {
  return SamaConnectionService.instance.sendRequest(conversationsRequest, {
    'ids': cids,
  }).then((response) {
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

Future<Conversation> updateConversation(
    String id,
    String? name,
    String? description,
    List<String>? addParticipants,
    List<String>? removeParticipants,
    Avatar? avatar) async {
  return SamaConnectionService.instance.sendRequest(conversationUpdate, {
    'id': id,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    'participants': {
      if (addParticipants != null) 'add': addParticipants,
      if (removeParticipants != null) 'remove': removeParticipants,
    },
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
