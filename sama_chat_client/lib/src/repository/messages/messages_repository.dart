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
  final limitMessages = 30;

  MessagesRepository(
      {required this.localDatasource, required this.userRepository}) {
    initChatListeners();
  }

  StreamSubscription<api.Message>? incomingMessagesSubscription;
  StreamSubscription<api.MessageSendStatus>? sentMessageSubscription;
  StreamSubscription<api.MessageSendStatus>? readMessagesSubscription;
  StreamSubscription<api.MessageSendStatus>? editMessageSubscription;
  StreamSubscription<api.MessageSendStatus>? deletedMessageSubscription;
  StreamSubscription<api.TypingStatus>? typingMessageSubscription;

  final StreamController<ChatMessage> _incomingMessagesController =
      StreamController.broadcast();

  Stream<ChatMessage> get incomingMessagesStream =>
      _incomingMessagesController.stream;

  final StreamController<api.MessageSendStatus> _statusMessagesController =
      StreamController.broadcast();

  Stream<api.MessageSendStatus> get statusMessagesStream =>
      _statusMessagesController.stream;

  final StreamController<api.TypingStatus> _typingMessageController =
      StreamController.broadcast();

  Stream<api.TypingStatus> get typingMessageStream =>
      _typingMessageController.stream;

  Future<Resource<List<ChatMessage>>> getAllMessages(ConversationModel chat,
      {DateTime? ltDate, DateTime? gtTime}) async {
    return NetworkBoundResources<List<ChatMessage>, List<MessageModel>>()
        .asFuture(
      loadFromDb: () => localDatasource.getAllMessagesLocal(chat.id,
          ltDate: ltDate, limit: limitMessages),
      shouldFetch: (oldData, slice) {
        var result = oldData != null && !listEquals(oldData, slice);
        return result;
      },
      createCallSlice: () =>
          _fetchMessages(chat, ltDate: ltDate, limit: limitMessages),
      saveCallResult: (newData, oldData) {
        List<String> idsToDelete = detectGapMessageIds(newData, oldData);
        localDatasource.removeMessagesLocal(idsToDelete);
        return localDatasource.saveMessagesLocal(newData);
      },
      processResponse: buildChatMessageModels,
    );
  }

  List<String> detectGapMessageIds(
      List<MessageModel> newData, List<MessageModel> oldData) {
    var difference = oldData
        .where((element) => !newData.map((m) => m.id).contains(element.id));
    return difference.map((m) => m.id).toList();
  }

  Future<List<MessageModel>> _fetchMessages(ConversationModel chat,
      {DateTime? ltDate, DateTime? gtTime, int limit = 100}) async {
    var messages = await api.getMessages({
      'cid': chat.id,
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

    return buildMessageModels(chat, messages);
  }

  Future<List<MessageModel>> _fetchMessagesByIds(
      ConversationModel chat, List<String> ids) async {
    var messages = await api.getMessages({
      'cid': chat.id,
      'ids': ids,
    });
    return buildMessageModels(chat, messages);
  }

  Future<void> getMessagesSummary(String cid, String filter) async {
    var messageBody = await api.getMessagesSummary({
      'cid': cid,
      'filter': filter,
    });
    var currentUser = await userRepository.getCurrentUser();
    var messageModel = MessageModel(
        body: messageBody,
        isOwn: true,
        cid: cid,
        from: currentUser!.id!,
        id: const Uuid().v1(),
        extension: const {'type': 'summary'},
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    _incomingMessagesController.add(messageModel.toChatMessage(true, true));
  }

  Future<String> changeMessageTone(String body, String tone) async {
    return await api.changeMessageTone({
      'body': body,
      'tone': tone,
    });
  }

  Future<List<ChatMessage>> getStoredMessagesByIds(
      ConversationModel chat, List<String> ids) async {
    var messages = await localDatasource.getMessagesLocal(ids);
    return buildChatMessageModels(messages);
  }

  Future<ChatMessage?> getReplyMessageById(
      ConversationModel chat, String id) async {
    var message = await localDatasource.getMessageLocalById(id);
    if (message == null) {
      message = (await _fetchMessagesByIds(chat, [id])).firstOrNull;
      message = message?.copyWith(isTempReplied: true);
      if (message != null) message = await saveMessageLocal(message);
    }

    if (message != null) {
      return (await buildChatMessageModels([message])).firstOrNull;
    }
    return null;
  }

  Future<List<ChatMessage>> getStoredMessages(ConversationModel chat,
      {int? limit}) async {
    var messages = await localDatasource.getAllMessagesLocal(chat.id,
        limit: limit ?? limitMessages);
    return buildChatMessageModels(messages);
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

  Future<void> sendTextMessage(
      String body, String cid, MessageModel? replyMessage) async {
    var currentUser = await userRepository.getCurrentUser();
    var message = api.Message(
        body: body.trim(),
        cid: cid,
        repliedMessageId: replyMessage?.id,
        from: currentUser?.id,
        id: const Uuid().v1(),
        rawStatus: ChatMessageStatus.none.name,
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    var msgModel = message
        .toMessageModel(true, currentUser!)
        .copyWith(replyMessage: replyMessage);
    _incomingMessagesController.add(msgModel.toChatMessage(true, true));

    return api.sendMessage(message: message).then((response) async {
      var (serverMid, msg) = response;
      if (serverMid == null) {
        var msgUpdated =
            msgModel.copyWith(rawStatus: ChatMessageStatus.pending.name);
        saveMessageLocal(msgUpdated);
        _statusMessagesController
            .add(api.PendingMessageStatus.fromJson({'mid': message.id}));
      }
      if (msg != null) {
        ChatMessage chatMessage;
        if (msg.extension?['modified'] ?? false) {
          chatMessage =
              msg.toMessageModel(true, currentUser).toChatMessage(true, true);
        } else {
          var sender = await userRepository.getUserById(msg.from ?? '');
          sender ??= UserModel();
          chatMessage =
              msg.toMessageModel(false, sender).toChatMessage(true, true);
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

  Future<void> editMessage(String body, MessageModel? editMessage) async {
    var editMessageStatus =
        api.EditMessageStatus(editMessage!.id, body, editMessage.from);

    return api.editMessage(editMessage.id, body).then((response) async {
      if (response) {
        var msgUpdated = editMessage.copyWith(body: body, isEdited: true);
        saveMessageLocal(msgUpdated);
        _statusMessagesController.add(editMessageStatus);
      }
    }).catchError((onError) {
      if (onError is api.ResponseException) {
        throw onError;
      }
    });
  }

  Future<bool> sendStatusReadMessages(String cid) {
    return api.readMessages(api.ReadMessagesStatus.fromJson({'cid': cid}));
  }

  Future<void> sendForwardMessages(
      ConversationModel chat, Set<MessageModel> message) async {
    for (var msg in message) {
      await _sendForwardMessage(chat.id,
          body: msg.body,
          attachments: msg.attachments.map((a) => a.toAttachment()).toList(),
          replyMessage: msg.replyMessage,
          forwardedMessageId: msg.id);
    }
  }

  Future<void> _sendForwardMessage(cid,
      {String? body,
      List<api.Attachment> attachments = const [],
      MessageModel? replyMessage,
      String? forwardedMessageId}) async {
    var currentUser = await userRepository.getCurrentUser();
    var message = api.Message(
        cid: cid,
        body: body?.trim(),
        attachments: attachments.isNotEmpty ? attachments : null,
        repliedMessageId: replyMessage?.id,
        forwardedMessageId: forwardedMessageId,
        from: currentUser?.id,
        id: const Uuid().v1(),
        rawStatus: ChatMessageStatus.none.name,
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    return api.sendMessage(message: message).then(
      (response) async {
        var (serverMid, msg) = response;
        var msgModel = message.toMessageModel(true, currentUser!).copyWith(
            id: serverMid,
            replyMessage: replyMessage,
            rawStatus: ChatMessageStatus.sent.name);
        var msgUpdated = await saveMessageLocal(msgModel);
        _incomingMessagesController.add(msgUpdated.toChatMessage(true, true));
      },
    );
  }

  Future<void> deleteMessage(
      String cid, List<String> ids, api.DeleteMessageType type) async {
    var deleteMessageStatus = api.DeleteMessagesStatus.fromJson(
        {'cid': cid, 'ids': ids, 'type': type.name});
    return api.deleteMessages(deleteMessageStatus).then(
      (response) async {
        if (response) {
          await localDatasource.removeMessagesLocal(ids);
          _statusMessagesController.add(deleteMessageStatus);
        }
      },
    ).catchError((onError) {
      if (onError is api.ResponseException) {
        throw onError;
      }
    });
  }

  Future<MessageModel> saveMessageLocal(MessageModel message) async {
    return await localDatasource.saveMessageLocal(message);
  }

  Future<void> saveDraftMessage(
      String body, String cid, MessageModel? replyMessage) async {
    var currentUser = await userRepository.getCurrentUser();
    var message = MessageModel(
        body: body.trim(),
        isOwn: true,
        cid: cid,
        from: currentUser!.id!,
        id: const Uuid().v1(),
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now(),
        rawStatus: ChatMessageStatus.draft.name)
      ..sender = currentUser
      ..replyMessage = replyMessage;

    var msg = await saveMessageLocal(message);
    _incomingMessagesController.add(msg.toChatMessage(true, true));
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

  Future<void> deleteMessagesLocal(List<String> ids) async {
    await localDatasource.removeMessagesLocal(ids);
  }

  void initChatListeners() {
    if (incomingMessagesSubscription != null) return;

    incomingMessagesSubscription = api
        .MessagesManager.instance.incomingMessagesStream
        .listen((message) async {
      var currentUser = await userRepository.getCurrentUser();
      var sender = await userRepository.getUserById(message.from ?? '');

      sender ??= UserModel();
      var msgModel =
          message.toMessageModel(currentUser?.id == message.from, sender);

      msgModel = await saveMessageLocal(msgModel);
      var chatMessage = msgModel.toChatMessage(true, true);

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

    editMessageSubscription = api
        .MessagesManager.instance.editMessageStatusStream
        .listen((editStatus) async {
      var message = await getMessageLocalById(editStatus.messageId);
      if (message != null) {
        await updateMessageLocal(
            message.copyWith(body: editStatus.newBody, isEdited: true));
      }

      _statusMessagesController.add(editStatus);
    });

    deletedMessageSubscription = api
        .MessagesManager.instance.deletedMessageStatusStream
        .listen((deletedStatus) async {
      await deleteMessagesLocal(deletedStatus.msgIds!);

      _statusMessagesController.add(deletedStatus);
    });

    typingMessageSubscription = api.TypingManager.instance.typingStatusStream
        .listen((typingStatus) async {
      _typingMessageController.add(typingStatus);
    });
  }

  void dispose() {
    incomingMessagesSubscription?.cancel();
    sentMessageSubscription?.cancel();
    readMessagesSubscription?.cancel();
    editMessageSubscription?.cancel();
    deletedMessageSubscription?.cancel();
    typingMessageSubscription?.cancel();
    api.MessagesManager.instance.destroy();
    api.TypingManager.instance.destroy();
  }

  Future<void> sendMediaMessage(cid,
      {String? body,
      List<api.Attachment> attachments = const [],
      MessageModel? replyMessage}) async {
    var currentUser = await userRepository.getCurrentUser();
    var message = api.Message(
        cid: cid,
        body: body?.trim(),
        attachments: attachments,
        repliedMessageId: replyMessage?.id,
        from: currentUser?.id,
        id: const Uuid().v1(),
        rawStatus: ChatMessageStatus.none.name,
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    return api.sendMessage(message: message).then(
      (_) {
        var msgModel = message
            .toMessageModel(true, currentUser!)
            .copyWith(replyMessage: replyMessage);
        _incomingMessagesController.add(msgModel.toChatMessage(true, true));
      },
    );
  }

  Future<void> sendTypingStatus(String cid) async {
    var typing = api.TypingMessageStatus.fromJson({'cid': cid});
    api.sendTypingStatus(typing);
  }

  Future<List<MessageModel>> buildMessageModels(
      ConversationModel chat, List<api.Message> messages) async {
    var result = <MessageModel>[];
    var currentUser = await userRepository.getCurrentUser();
    var participants = {}..addEntries(chat.participants
        .map((participant) => MapEntry(participant.id!, participant)));

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      var isOwn = currentUser?.id == message.from;
      var sender = participants[message.from] ??
          await userRepository.getUserById(message.from!);
      var messageModel = message.toMessageModel(isOwn, sender);
      result.add(messageModel);
    }
    return result;
  }

  Future<List<ChatMessage>> buildChatMessageModels(
      List<MessageModel> messages) async {
    var result = <ChatMessage>[];

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];

      var chatMessage = message.toChatMessage(
          i == 0 ||
              isServiceMessage(messages[i - 1]) ||
              messages[i - 1].from != messages[i].from,
          i == messages.length - 1 ||
              isServiceMessage(messages[i + 1]) ||
              messages[i + 1].from != messages[i].from);

      result.add(chatMessage);
    }
    return result;
  }
}

bool isServiceMessage(MessageModel message) {
  return message.extension != null && message.extension?['type'] != null;
}
