import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../api/api.dart' as api;
import '../../db/local/message_local_datasource.dart';
import '../../db/models/models.dart';
import '../../db/network_bound_resource.dart';
import '../../db/resource.dart';
import '../../features/conversation/models/models.dart';
import '../user/user_repository.dart';

class MessagesRepository {
  final MessageLocalDatasource localDatasource;
  final UserRepository userRepository;

  MessagesRepository(
      {required this.localDatasource, required this.userRepository}) {
    initChatListeners();
  }

  StreamSubscription<api.Message>? incomingMessagesSubscription;
  StreamSubscription<api.MessageSendStatus>? sentMessageSubscription;
  StreamSubscription<api.MessageSendStatus>? readMessagesSubscription;

  final StreamController<ChatMessage> _incomingMessagesController =
      StreamController.broadcast();

  Stream<ChatMessage> get incomingMessagesStream =>
      _incomingMessagesController.stream;

  final StreamController<api.MessageSendStatus> _statusMessagesController =
      StreamController.broadcast();

  Stream<api.MessageSendStatus> get statusMessagesStream =>
      _statusMessagesController.stream;

  Future<Resource<List<ChatMessage>>> getAllMessages(ConversationModel chat,
      {DateTime? ltDate, DateTime? gtTime}) async {
    return NetworkBoundResources<List<ChatMessage>, List<MessageModel>>()
        .asFuture(
      loadFromDb: () =>
          localDatasource.getAllMessagesLocal(chat.id, ltDate: ltDate),
      shouldFetch: (data, slice) {
        var oldData = data?.take(10).toList();
        var result = data != null && !listEquals(oldData, slice);
        return result;
      },
      createCallSlice: () =>
          _fetchMessages(chat.id, ltDate: ltDate ?? DateTime.now(), limit: 10),
      createCall: () => _fetchMessages(chat.id, ltDate: ltDate, gtTime: gtTime),
      saveCallResult: localDatasource.saveMessagesLocal,
      processResponse: (data) async {
        var currentUser = await userRepository.getCurrentUser();

        var participants = {}..addEntries(chat.participants
            .map((participant) => MapEntry(participant.id!, participant)));

        var result = <ChatMessage>[];

        for (int i = 0; i < data.length; i++) {
          var message = data[i];
          var sender = participants[message.from] ??
              await userRepository.getUserById(message.from!);
          var isOwn = currentUser?.id == message.from;
          var chatMessage = message.toChatMessage(
              sender ?? UserModel(),
              isOwn,
              i == 0 ||
                  isServiceMessage(data[i - 1]) ||
                  data[i - 1].from != data[i].from,
              i == data.length - 1 ||
                  isServiceMessage(data[i + 1]) ||
                  data[i + 1].from != data[i].from,
              isOwn ? ChatMessageStatus.sent : ChatMessageStatus.none);
          result.add(chatMessage);
        }
        return result;
      },
    );
  }

  Future<List<MessageModel>> _fetchMessages(String cid,
      {DateTime? ltDate, DateTime? gtTime, int limit = 100}) async {
    var messages = await api.getMessages({
      'cid': cid,
      if (ltDate != null)
        'updated_at': {
          'lt': ltDate.toUtc().toIso8601String(),
        },
      if (gtTime != null)
        'updated_at': {
          'gt': gtTime.toIso8601String(),
        },
      'limit': limit,
    });

    var result = <MessageModel>[];
    var currentUser = await userRepository.getCurrentUser();
    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      var isOwn = currentUser?.id == message.from;
      var messageModel = message.toMessageModel(isOwn: isOwn);
      result.add(messageModel);
    }
    return result;
  }

  Future<List<ChatMessage>> getStoredMessages(ConversationModel chat) async {
    var messages = await localDatasource.getAllMessagesLocal(chat.id);
    var currentUser = await userRepository.getCurrentUser();

    var participants = {}..addEntries(chat.participants
        .map((participant) => MapEntry(participant.id!, participant)));

    var result = <ChatMessage>[];

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      var sender = participants[message.from] ??
          await userRepository.getUserById(message.from!);
      var isOwn = currentUser?.id == message.from;

      var chatMessage = message.toChatMessage(
          sender ?? UserModel(),
          isOwn,
          i == 0 ||
              isServiceMessage(messages[i - 1]) ||
              messages[i - 1].from != messages[i].from,
          i == messages.length - 1 ||
              isServiceMessage(messages[i + 1]) ||
              messages[i + 1].from != messages[i].from,
          isOwn ? ChatMessageStatus.sent : ChatMessageStatus.none);

      result.add(chatMessage);
    }
    return result;
  }

  Future<MessageModel?> getMessageLocalById(String id) {
    return localDatasource.getMessageLocalById(id);
  }

  Future<MessageModel?> getMessageLocalByStatus(String cid, String status) {
    return localDatasource.getMessageLocalByStatus(cid, status);
  }

  Future<List<MessageModel>> getMessagesLocalByStatus(String status) {
    return localDatasource.getMessagesLocalByStatus(status);
  }

  Future<void> resendTextMessage(MessageModel message) async {
    var msg = api.Message(
        body: message.body,
        cid: message.cid,
        from: message.from,
        id: message.id,
        t: message.t,
        createdAt: message.createdAt);
    await Future.delayed(const Duration(milliseconds: 100), () {
      api.sendMessage(message: msg); // TODO RP shouldRetry - true?
    });
  }

  Future<void> sendTextMessage(String body, String cid) async {
    var currentUser = await userRepository.getCurrentUser();
    var message = api.Message(
        body: body.trim(),
        cid: cid,
        from: currentUser?.id,
        id: const Uuid().v1(),
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    var msgModel =
        message.toMessageModel().toChatMessage(currentUser!, true, true, true);
    _incomingMessagesController.add(msgModel);

    return api.sendMessage(message: message).then((response) async {
      var (result, msg) = response;
      if (!result) {
        var msgUpdated = msgModel.copyWith(rawStatus: 'pending');
        saveMessageLocal(msgUpdated);
        _statusMessagesController
            .add(api.PendingMessageStatus.fromJson({'mid': message.id}));
      }
      if (msg != null) {
        ChatMessage chatMessage;
        if (msg.extension?['modified'] ?? false) {
          chatMessage =
              msg.toMessageModel().toChatMessage(currentUser, true, true, true);
        } else {
          var sender = await userRepository.getUserById(msg.from ?? '');
          sender ??= UserModel();
          chatMessage =
              msg.toMessageModel().toChatMessage(sender, false, true, true);
        }
        _incomingMessagesController.add(chatMessage);
      }
    }).catchError((onError) {
      if (onError is api.ResponseException) {
        _statusMessagesController
            .add(api.FailedMessagesStatus.fromJson({'mid': message.id}));
        throw onError;
      }
    });
  }

  Future<bool> sendStatusReadMessages(String cid) {
    return api.readMessages(api.ReadMessagesStatus.fromJson({'cid': cid}));
  }

  Future<MessageModel> saveMessageLocal(MessageModel message) async {
    return await localDatasource.saveMessageLocal(message);
  }

  Future<void> saveDraftMessage(String body, String cid) async {
    var currentUser = await userRepository.getCurrentUser();
    var message = MessageModel(
        body: body.trim(),
        cid: cid,
        from: currentUser?.id,
        id: const Uuid().v1(),
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now(),
        rawStatus: ChatMessageStatus.draft.name);

    var msg = await saveMessageLocal(message);
    _incomingMessagesController
        .add(msg.toChatMessage(currentUser!, true, true, true));
  }

  Future<MessageModel> updateMessageLocal(MessageModel message) async {
    return await localDatasource.updateMessageLocal(message);
  }

  Future<void> updateMessagesLocal(List<MessageModel> messages) async {
    await localDatasource.updateMessagesLocal(messages);
  }

  Future<void> deleteMessageLocal(String id) async {
    await localDatasource.removeMessageLocal(id);
  }

  void initChatListeners() {
    if (incomingMessagesSubscription != null) return;

    incomingMessagesSubscription = api
        .MessagesManager.instance.incomingMessagesStream
        .listen((message) async {
      var currentUser = await userRepository.getCurrentUser();
      var sender = await userRepository.getUserById(message.from ?? '');

      sender ??= UserModel();
      var msgModel = message.toMessageModel();
      var chatMessage = msgModel.toChatMessage(
          sender, currentUser?.id == message.from, true, true);

      _incomingMessagesController.add(chatMessage);
    });

    sentMessageSubscription = api
        .MessagesManager.instance.sentMessageStatusStream
        .listen((sentStatus) async {
      _statusMessagesController.add(sentStatus);
    });

    readMessagesSubscription = api
        .MessagesManager.instance.readMessagesStatusStream
        .listen((readStatus) async {
      _statusMessagesController.add(readStatus);
    });
  }

  void dispose() {
    incomingMessagesSubscription?.cancel();
    sentMessageSubscription?.cancel();
    readMessagesSubscription?.cancel();
    api.MessagesManager.instance.destroy();
  }

  Future<void> sendMediaMessage(cid,
      {String? body, List<api.Attachment> attachments = const []}) async {
    var currentUser = await userRepository.getCurrentUser();
    var message = api.Message(
        cid: cid,
        body: body?.trim(),
        attachments: attachments,
        from: currentUser?.id,
        id: const Uuid().v1(),
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    return api.sendMessage(message: message).then(
      (_) {
        var msgModel = message.toMessageModel();
        _incomingMessagesController
            .add(msgModel.toChatMessage(currentUser!, true, true, true));
      },
    );
  }
}

bool isServiceMessage(MessageModel message) {
  return message.extension != null && message.extension?['type'] != null;
}
