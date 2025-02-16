import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../api/api.dart' as api;
import '../../db/models/models.dart';
import '../../features/conversation/models/models.dart';
import '../user/user_repository.dart';

class MessagesRepository {
  final UserRepository userRepository;

  MessagesRepository({required this.userRepository}) {
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

  Future<List<ChatMessage>> getMessages(
    String cid, {
    Map<String, dynamic>? parameters,
  }) async {
    var messages = await api.getMessages({
      'cid': cid,
      if (parameters != null && parameters.isNotEmpty) ...parameters
    });

    var currentUser = await userRepository.getCurrentUser();

    var users = await userRepository.getUsersByCids([cid]);
    var participants = {}..addEntries(
        users.map((participant) => MapEntry(participant.id!, participant)));

    var result = <ChatMessage>[];

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      var sender = participants[message.from] ?? UserModel();
      var isOwn = currentUser?.id == message.from;

      var chatMessage = message.toChatMessage(
          sender,
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

  Future<void> sendTextMessage(String body, String cid) async {
    var message = api.Message(
        body: body.trim(),
        cid: cid,
        id: const Uuid().v1(),
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    var currentUser = await userRepository.getCurrentUser();

    _incomingMessagesController
        .add(message.toChatMessage(currentUser!, true, true, true));

    return api.sendMessage(message: message).then((result) {
      if (!result) {
        _statusMessagesController
            .add(api.PendingMessageStatus.fromJson({'mid': message.id}));
      }
    });
  }

  Future<bool> sendStatusReadMessages(String cid) {
    return api.readMessages(api.ReadMessagesStatus.fromJson({'cid': cid}));
  }

  void initChatListeners() {
    if (incomingMessagesSubscription != null) return;

    incomingMessagesSubscription = api
        .MessagesManager.instance.incomingMessagesStream
        .listen((message) async {
      var currentUser = await userRepository.getCurrentUser();
      var sender = await userRepository.getUserById(message.from ?? '');

      sender ??= UserModel();

      var chatMessage = message.toChatMessage(
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
      {String? body, List<api.Attachment> attachments = const []}) {
    var message = api.Message(
        cid: cid,
        body: body?.trim(),
        attachments: attachments,
        id: const Uuid().v1(),
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        createdAt: DateTime.now());

    return api.sendMessage(message: message).then(
      (_) async {
        var currentUser = await userRepository.getCurrentUser();

        _incomingMessagesController
            .add(message.toChatMessage(currentUser!, true, true, true));
      },
    );
  }
}

bool isServiceMessage(api.Message message) {
  return message.extension != null && message.extension?['type'] != null;
}
