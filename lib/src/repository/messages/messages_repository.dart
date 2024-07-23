import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../api/api.dart' as api;
import '../../features/conversation/models/models.dart';
import '../user/user_repository.dart';

class MessagesRepository {
  final UserRepository userRepository;
  final Map<String, api.User> participants = {};

  MessagesRepository({
    required this.userRepository,
  });

  StreamSubscription<api.Message>? incomingMessagesSubscription;

  final StreamController<ChatMessage> _incomingMessagesController =
      StreamController.broadcast();

  Stream<ChatMessage> get incomingMessagesStream =>
      _incomingMessagesController.stream;

  Future<List<ChatMessage>> getMessages(
    String cid, {
    Map<String, dynamic>? parameters,
  }) async {
    var messages = await api
        .getMessages({'cid': cid, if (parameters != null) ...parameters});

    var currentUser = await userRepository.getUser();

    await api.fetchParticipants([cid]).then((participants) {
      this.participants.addEntries(participants
          .map((participant) => MapEntry(participant.id!, participant)));
    });

    var result = <ChatMessage>[];

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      var sender = participants[message.from]!;

      var chatMessage = ChatMessage(
          sender: sender,
          isOwn: currentUser?.id == message.from,
          isLastUserMessage: i == 0 ||
              isServiceMessage(messages[i - 1]) ||
              messages[i - 1].from != messages[i].from,
          isFirstUserMessage: i == messages.length - 1 ||
              isServiceMessage(messages[i + 1]) ||
              messages[i + 1].from != messages[i].from,
          id: message.id,
          from: message.from,
          cid: message.cid,
          status: message.status,
          body: message.body,
          attachments: message.attachments,
          createdAt: message.createdAt,
          t: message.t,
          extension: message.extension);

      result.add(chatMessage);
    }

    return result;
  }

  Future<void> sendTextMessage(String body, String cid) {
    var message = api.Message(
        body: body.trim(),
        cid: cid,
        id: const Uuid().v1(),
        t: DateTime.now().millisecondsSinceEpoch ~/ 1000);

    return api.sendMessage(message: message).then((_) async {
      var currentUser = await userRepository.getUser();

      _incomingMessagesController.add(ChatMessage(
          sender: currentUser!,
          isOwn: true,
          //will be calculated before add to list
          isFirstUserMessage: true,
          isLastUserMessage: true,
          id: message.id,
          from: currentUser.id,
          cid: message.cid,
          status: message.status,
          body: message.body,
          attachments: message.attachments,
          createdAt: message.createdAt,
          t: message.t,
          extension: message.extension));
    });
  }

  void initChatListeners() {
    if (incomingMessagesSubscription != null) return;

    api.MessagesManager.instance.init();
    incomingMessagesSubscription = api
        .MessagesManager.instance.incomingMessagesStream
        .listen((message) async {
      var currentUser = await userRepository.getUser();
      var sender = participants[message.from];

      if (sender == null) {
        await api.getUsersByIds({message.from!}).then((users) {
          participants
              .addEntries(users.map((user) => MapEntry(user.id!, user)));
        });
      }

      sender ??= participants[message.from] ?? api.User.empty;

      var chatMessage = ChatMessage(
        sender: sender,
        isOwn: currentUser?.id == message.from,
        //will be calculated before add to list
        isFirstUserMessage: true,
        // will be calculated before add to list
        isLastUserMessage: true,
        id: message.id,
        from: message.from ?? currentUser?.id,
        cid: message.cid,
        status: message.status,
        body: message.body,
        attachments: message.attachments,
        createdAt: message.createdAt,
        t: message.t,
        extension: message.extension,
      );

      _incomingMessagesController.add(chatMessage);
    });
  }

  void destroyChatListeners() {
    incomingMessagesSubscription?.cancel();
    incomingMessagesSubscription = null;
    api.MessagesManager.instance.destroy();
  }
}

bool isServiceMessage(api.Message message) {
  return message.extension != null && message.extension?['type'] != null;
}
