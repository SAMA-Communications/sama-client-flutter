import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../api/api.dart' as api;
import '../../api/api.dart';
import '../../db/models/conversation.dart';
import '../../repository/messages/messages_repository.dart';
import '../../shared/utils/media_utils.dart';
import '../user/user_repository.dart';
import 'conversation_data_source.dart';

class ConversationRepository {
  final ConversationLocalDataSource localDataSource;
  final UserRepository userRepository;
  final MessagesRepository messagesRepository;

  ConversationRepository(
      {required this.localDataSource,
      required this.userRepository,
      required this.messagesRepository}) {
    initChatListeners();
  }

  StreamSubscription<api.SystemMessage>? incomingSystemMessagesSubscription;

  final StreamController<ConversationModel> _incomingMessageController =
      StreamController.broadcast();

  StreamSubscription<api.Message>? incomingMessagesSubscription;

  Stream<ConversationModel> get updateConversationStream =>
      _incomingMessageController.stream;

  void initChatListeners() {
    if (incomingSystemMessagesSubscription != null) return;

    incomingSystemMessagesSubscription = api
        .MessagesManager.instance.systemChatMessagesStream
        .listen((message) async {
      Map<String, User> participants = await userRepository.getUsersByIds([
        message.from!,
        if (message.conversation?.opponentId != null)
          message.conversation!.opponentId!
      ]);

      final conversation = ConversationModel(
          id: message.conversation!.id!,
          createdAt: message.conversation!.createdAt!,
          updatedAt: message.conversation!.updatedAt!,
          type: message.conversation!.type!,
          name: message.conversation!.type! == 'g'
              ? message.conversation!.name!
              : null,
          opponent: participants[message.conversation!.opponentId],
          owner: participants[message.conversation!.ownerId],
          unreadMessagesCount: message.conversation!.unreadMessagesCount,
          lastMessage: message.conversation!.lastMessage,
          description: message.conversation!.description);
      if (message.type == SystemChatMessageType.conversationCreated) {
        localDataSource.addConversation(conversation);
      } else if (message.type == SystemChatMessageType.conversationUpdated) {
        final conversationStored =
            localDataSource.getConversationsMap()[message.cid];
        if (conversationStored != null) {
          var updatedConversation =
              conversationStored.copyWithItem(item: conversation);
          localDataSource.updateConversation(updatedConversation);
        } else {
          localDataSource.addConversation(conversation);
        }
      }
      _incomingMessageController.add(conversation);
    });

    incomingMessagesSubscription =
        messagesRepository.incomingMessagesStream.listen((message) async {
      final conversation = localDataSource.getConversationsMap()[message.cid];
      if (conversation != null) {
        int? unreadMsgCountUpdated;
        if (!message.isOwn) {
          unreadMsgCountUpdated = (conversation.unreadMessagesCount ?? 0) + 1;
        }

        final updatedConversation = conversation.copyWith(
            lastMessage: message, unreadMessagesCount: unreadMsgCountUpdated);
        localDataSource.updateConversation(updatedConversation);
        _incomingMessageController.add(updatedConversation);
      }
    });
  }

  void dispose() {
    incomingSystemMessagesSubscription?.cancel();
    incomingSystemMessagesSubscription = null;
    incomingMessagesSubscription?.cancel();
    incomingMessagesSubscription = null;
    api.MessagesManager.instance.destroy();
  }

  Future<List<ConversationModel>> getStoredConversations() async {
    var conversations = localDataSource.getConversationsList();
    _removeEmptyPrivateConversations(conversations);
    _sortConversations(conversations);
    return conversations;
  }

  Future<List<api.Conversation>> getConversations() async {
    //FixME RP later with storage mechanism
    // if (localDataSource.conversations.isNotEmpty) return localDataSource.conversations;

    return api.fetchConversations();
  }

  Future<List<api.User>> getParticipants(List<String> cids) async {
    //FixME RP later with storage mechanism
    // if (_participants.isNotEmpty) return _participants.values.toList();

    return api.fetchParticipants(cids);
  }

  Future<List<ConversationModel>> getConversationsWithParticipants() async {
    final List<api.Conversation> conversations = await getConversations();

    final List<String> cids =
        conversations.map((element) => element.id!).toList();
    final List<User> participants = await getParticipants(cids);
    Map<String, User> participantsMap = {for (var v in participants) v.id!: v};

    final List<ConversationModel> result = conversations
        .map(
          (element) => ConversationModel(
            id: element.id!,
            createdAt: element.createdAt!,
            updatedAt: element.updatedAt!,
            type: element.type!,
            name: element.type! == 'g' ? element.name! : null,
            opponent: participantsMap[element.opponentId],
            owner: participantsMap[element.ownerId],
            unreadMessagesCount: element.unreadMessagesCount,
            lastMessage: element.lastMessage,
            description: element.description,
          ),
        )
        .toList();

    localDataSource.setConversations({for (var v in result) v.id: v});
    _sortConversations(result);
    _removeEmptyPrivateConversations(result);
    return result;
  }

  Future<ConversationModel> createConversation(
      List<api.User> participants, String type,
      [String? name, File? avatarUrl]) async {
    Avatar? avatar;
    if (avatarUrl != null) {
      var compressedFile =
          await compressImageFile(avatarUrl, const Size(640, 480));
      final blur = await getImageHashInIsolate(compressedFile);
      final id = await api.uploadAvatarFile(compressedFile);
      final name = basename(compressedFile.path);
      avatar = Avatar(fileId: id, fileName: name, fileBlurHash: blur);
    }

    final Conversation conversation = await api.createConversation(
        participants.map((user) => user.id!).toList(), type, name, avatar);
    final participantsMap = {for (var v in participants) v.id!: v};

    var result = ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: conversation.type! == 'g' ? conversation.name! : null,
        opponent: participantsMap[conversation.opponentId],
        owner: participantsMap[conversation.ownerId],
        unreadMessagesCount: conversation.unreadMessagesCount,
        lastMessage: conversation.lastMessage,
        avatar: conversation.avatar);

    localDataSource.addConversation(result);
    return result;
  }

  void _sortConversations(List<ConversationModel> items) {
    items.sort((a, b) => (b.lastMessage?.createdAt ?? b.updatedAt)
        .compareTo(a.lastMessage?.createdAt ?? a.updatedAt));
  }

  void _removeEmptyPrivateConversations(List<ConversationModel> items) {
    items.removeWhere((i) => i.type == 'u' && i.lastMessage == null);
  }
}
