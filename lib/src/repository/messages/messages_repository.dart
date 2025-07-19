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
      loadFromDb: () =>
          localDatasource.getAllMessagesLocal(chat.id, ltDate: ltDate),
      shouldFetch: (data, slice) {
        var oldData = data?.take(10).toList();
        var result = data != null && !listEquals(oldData, slice);
        return result;
      },
      createCallSlice: () =>
          _fetchMessages(chat, ltDate: ltDate ?? DateTime.now(), limit: 10),
      createCall: () => _fetchMessages(chat, ltDate: ltDate, gtTime: gtTime),
      saveCallResult: localDatasource.saveMessagesLocal,
      processResponse: (data) async {
        return buildChatMessageModels(chat, data);
      },
    );
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

  Future<List<ChatMessage>> getStoredMessagesByIds(
      ConversationModel chat, List<String> ids) async {
    var messages = await localDatasource.getMessagesLocal(ids);
    return buildChatMessageModels(chat, messages);
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
      return (await buildChatMessageModels(chat, [message])).firstOrNull;
    }
    return null;
  }

  Future<List<ChatMessage>> getStoredMessages(ConversationModel chat,
      {int? limit}) async {
    var messages =
        await localDatasource.getAllMessagesLocal(chat.id, limit: limit);
    return buildChatMessageModels(chat, messages);
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
      var (result, msg) = response;
      if (!result) {
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

  Future<bool> sendStatusReadMessages(String cid) {
    return api.readMessages(api.ReadMessagesStatus.fromJson({'cid': cid}));
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

    typingMessageSubscription = api.TypingManager.instance.typingStatusStream
        .listen((typingStatus) async {
      _typingMessageController.add(typingStatus);
    });
  }

  void dispose() {
    incomingMessagesSubscription?.cancel();
    sentMessageSubscription?.cancel();
    readMessagesSubscription?.cancel();
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
      ConversationModel chat, List<MessageModel> messages) async {
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
