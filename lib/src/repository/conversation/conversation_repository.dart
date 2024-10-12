import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../api/api.dart' as api;
import '../../api/api.dart';
import '../../db/models/conversation.dart';
import '../../repository/messages/messages_repository.dart';
import '../../shared/utils/media_utils.dart';
import '../../shared/utils/string_utils.dart';
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

  final StreamController<ConversationModel> _conversationsController =
      StreamController.broadcast();

  StreamSubscription<api.Message>? incomingMessagesSubscription;

  Stream<ConversationModel> get updateConversationStream =>
      _conversationsController.stream;

  void initChatListeners() {
    if (incomingSystemMessagesSubscription != null) return;

    incomingSystemMessagesSubscription = api
        .MessagesManager.instance.systemChatMessagesStream
        .listen((message) async {
      Map<String, User?> participants = await userRepository.getUsersByIds([
        message.from!,
        if (message.conversation?.opponentId != null)
          message.conversation!.opponentId!
      ]);

      var localUser = await userRepository.getLocalUser();
      final opponent = participants[message.conversation!.opponentId];
      final owner = participants[message.conversation!.ownerId];

      final conversation = ConversationModel(
          id: message.conversation!.id!,
          createdAt: message.conversation!.createdAt!,
          updatedAt: message.conversation!.updatedAt!,
          type: message.conversation!.type!,
          name: getConversationName(
              message.conversation!, owner, opponent, localUser),
          opponent: getConversationOpponent(owner, opponent, localUser),
          owner: owner,
          unreadMessagesCount: message.conversation!.unreadMessagesCount,
          lastMessage: message.conversation!.lastMessage,
          description: message.conversation!.description,
          avatar: getConversationAvatar(
              message.conversation!, owner, opponent, localUser));
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
      } else if (message.type == SystemChatMessageType.conversationKicked) {
        localDataSource.removeConversation(message.cid);
      }
      _conversationsController.add(conversation);
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
        _conversationsController.add(updatedConversation);
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

  void resetUnreadMessagesCount(String conversationId) {
    final conversation = localDataSource.getConversationById(conversationId)!;
    final updatedConversation = conversation.copyWith(unreadMessagesCount: 0);
    localDataSource.updateConversation(updatedConversation);
    _conversationsController.add(updatedConversation);
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

    var localUser = await userRepository.getLocalUser();

    final List<ConversationModel> result = conversations.map((element) {
      final opponent = participantsMap[element.opponentId];
      final owner = participantsMap[element.ownerId];

      return ConversationModel(
        id: element.id!,
        createdAt: element.createdAt!,
        updatedAt: element.updatedAt!,
        type: element.type!,
        name: getConversationName(element, owner, opponent, localUser),
        opponent: getConversationOpponent(owner, opponent, localUser),
        owner: owner,
        unreadMessagesCount: element.unreadMessagesCount,
        lastMessage: element.lastMessage,
        description: element.description,
        avatar: getConversationAvatar(element, owner, opponent, localUser),
      );
    }).toList();

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

    var localUser = await userRepository.getLocalUser();
    final opponent = participantsMap[conversation.opponentId];
    final owner = participantsMap[conversation.ownerId];

    var result = ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: getConversationName(conversation, owner, opponent, localUser),
        opponent: getConversationOpponent(owner, opponent, localUser),
        owner: owner,
        unreadMessagesCount: conversation.unreadMessagesCount,
        lastMessage: conversation.lastMessage,
        avatar:
            getConversationAvatar(conversation, owner, opponent, localUser));

    localDataSource.addConversation(result);
    return result;
  }

  Future<bool> deleteConversation(String id) async {
    var result = await api.deleteConversation(id);
    if (result) localDataSource.removeConversation(id);
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
