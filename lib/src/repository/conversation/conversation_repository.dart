import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../api/api.dart' as api;
import '../../api/api.dart';
import '../../api/push_notifications/models/models.dart';
import '../../db/models/models.dart';
import '../../db/network_bound_resource.dart';
import '../../db/resource.dart';
import '../../repository/messages/messages_repository.dart';
import '../../shared/utils/media_utils.dart';
import '../../shared/utils/string_utils.dart';
import '../user/user_repository.dart';
import '../../db/local/conversation_local_datasource.dart';

class ConversationRepository {
  final ConversationLocalDatasource localDatasource;

  // final ConversationRemoteDataSource remoteDatasource;

  final UserRepository userRepository;
  final MessagesRepository messagesRepository;

  ConversationRepository(
      {required this.localDatasource,
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
      Map<String, UserModel?> participants =
          await userRepository.getUsersByIds([
        message.from!,
        if (message.conversation?.opponentId != null)
          message.conversation!.opponentId!
      ]);

      var currentUser = await userRepository.getCurrentUser();
      final opponent = participants[message.conversation!.opponentId] ??
          participants[message.from!];
      final owner = participants[message.conversation!.ownerId];

      final conversation = ConversationModel(
          id: message.conversation!.id!,
          createdAt: message.conversation!.createdAt!,
          updatedAt: message.conversation!.updatedAt!,
          type: message.conversation!.type!,
          name: getConversationName(
              message.conversation!, owner, opponent, currentUser),
          unreadMessagesCount: message.conversation!.unreadMessagesCount,
          description: message.conversation!.description)
        ..opponent = getConversationOpponent(owner, opponent, currentUser)
        ..owner = owner
        ..lastMessage = message.conversation!.lastMessage?.toMessageModel()
        ..avatar = getConversationAvatar(
            message.conversation!, owner, opponent, currentUser);

      if (message.type == SystemChatMessageType.conversationCreated) {
        localDatasource.saveConversationLocal(conversation);
      } else if (message.type == SystemChatMessageType.conversationUpdated) {
        final conversationStored =
            await localDatasource.getConversationLocal(message.cid);
        if (conversationStored != null) {
          var updatedConversation =
              conversationStored.copyWithItem(item: conversation);
          localDatasource.updateConversationLocal(updatedConversation);
        } else {
          localDatasource.saveConversationLocal(conversation);
        }
      } else if (message.type == SystemChatMessageType.conversationKicked) {
        localDatasource.removeConversationLocal(message.cid);
      }
      _conversationsController.add(conversation);

      api.showNotificationIfAppPaused(PushMessageData(
          cid: conversation.id,
          title: conversation.name,
          body: getSystemMessagePushBody(conversation, message, opponent)));
    });

    incomingMessagesSubscription =
        messagesRepository.incomingMessagesStream.listen((message) async {
      final conversation =
          await localDatasource.getConversationLocal(message.cid!);
      if (conversation != null) {
        int? unreadMsgCountUpdated;
        if (!message.isOwn) {
          unreadMsgCountUpdated = (conversation.unreadMessagesCount ?? 0) + 1;
        }

        final updatedConversation = conversation.copyWith(
            lastMessage: message.toMessageModel(),
            unreadMessagesCount: unreadMsgCountUpdated,
            updatedAt: message.createdAt);
        localDatasource.updateConversationLocal(updatedConversation);
        _conversationsController.add(updatedConversation);

        api.showNotificationIfAppPaused(PushMessageData(
            cid: updatedConversation.id,
            title: updatedConversation.name,
            body: updatedConversation.lastMessage?.body,
            firstAttachmentFileId: updatedConversation
                .lastMessage?.attachments.firstOrNull?.fileId));
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

  Future<void> resetUnreadMessagesCount(String conversationId) async {
    final conversation =
        await localDatasource.getConversationLocal(conversationId);
    final updatedConversation = conversation?.copyWith(unreadMessagesCount: 0);
    localDatasource.updateConversationLocal(updatedConversation!);
    _conversationsController.add(updatedConversation);
  }

  Future<List<ConversationModel>> getStoredConversations() async {
    var conversations = await localDatasource.getAllConversationsLocal();
    return conversations;
  }

  Future<List<UserModel>> getParticipants(List<String> cids) async {
    var users = (await api.fetchParticipants(cids))
        .map((element) => element.toUserModel())
        .toList();
    var usersLocal = await userRepository.saveUsersLocal(users);
    return usersLocal;
  }

  Future<Map<String, UserModel>> getParticipantsAsMap(List<String> cids) async {
    return {for (var v in await getParticipants(cids)) v.id!: v};
  }

  //FIXME RP uncomment after server fix
  Future<Resource<List<ConversationModel>>> getAllConversations() async {
    return NetworkBoundResources<List<ConversationModel>,
            List<ConversationModel>>()
        .asFuture(
      loadFromDb: localDatasource.getAllConversationsLocal,
      shouldFetch: (data, slice) {
        // var oldData = data?.take(10).toList();
        // var result = data != null && !listEquals(oldData, slice);
        return true;
      },
      // createCallSlice: () => _fetchConversationsWithParticipants(10),
      createCall: _fetchConversationsWithParticipants,
      saveCallResult: localDatasource.saveConversationsLocal,
    );
  }

  Future<Resource<ConversationModel?>> getConversation(String id) async {
    return NetworkBoundResources<ConversationModel?, ConversationModel?>()
        .asFuture(
      loadFromDb: () => localDatasource.getConversationLocal(id),
      shouldFetch: (data, slice) => data == null,
      createCall: () => getConversationById(id),
      saveCallResult: (data) => data != null
          ? localDatasource.saveConversationLocal(data)
          : Future.value(false),
    );
  }

  Future<List<ConversationModel>> getConversationsByIds(
      List<String> ids) async {
    return localDatasource.getConversationsLocal(ids);
  }

  Future<List<ConversationModel>> _fetchConversationsWithParticipants(
      [int limit = 100]) async {
    final conversations = await api.fetchConversations({
      // 'updated_at': {
      //   'lt': DateTime.now().toIso8601String(),
      // },
      'limit': limit,
    });

    final currentUser = await userRepository.getCurrentUser();
    final cids = conversations.map((element) => element.id!).toList();
    var usersMap = await getParticipantsAsMap(cids);

    List<ConversationModel> result =
        conversations.fold<List<ConversationModel>>([], (prev, conversation) {
      if (conversation.type == 'u' && conversation.lastMessage == null) {
        return prev;
      }
      var chat = _buildConversationModel(conversation, usersMap, currentUser);
      prev.add(chat);
      return prev;
    }).toList();

    return result;
  }

  Future<ConversationModel?> getConversationById(String cid) async {
    var conversation = await localDatasource.getConversationLocal(cid);

    if (conversation == null) {
      final conversation = (await fetchConversationsByIds([cid])).firstOrNull;
      if (conversation == null) return null;
      final currentUser = await userRepository.getCurrentUser();
      final participants = await getParticipantsAsMap([cid]);
      return _buildConversationModel(conversation, participants, currentUser);
    }
    return conversation;
  }

  Future<ConversationModel> createConversation(
      List<UserModel> participants, String type,
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

    var currentUser = await userRepository.getCurrentUser();
    final opponent = participantsMap[conversation.opponentId];
    final owner = currentUser;
    var result = ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: getConversationName(conversation, owner, opponent, currentUser),
        unreadMessagesCount: conversation.unreadMessagesCount)
      ..opponent = getConversationOpponent(owner, opponent, currentUser)
      ..owner = owner
      ..lastMessage = conversation.lastMessage?.toMessageModel()
      ..avatar =
          getConversationAvatar(conversation, owner, opponent, currentUser);

    localDatasource.saveConversationLocal(result); //
    // TODO RP check (added cause group is not shown if empty)
    _conversationsController.add(result);
    return result;
  }

  Future<ConversationModel?> updateConversation(
      {required String id,
      String? name,
      String? description,
      Set<UserModel>? addParticipants,
      Set<UserModel>? removeParticipants,
      File? avatarUrl}) async {
    Avatar? avatar;
    if (avatarUrl != null) {
      var compressedFile =
          await compressImageFile(avatarUrl, const Size(640, 480));
      final blur = await getImageHashInIsolate(compressedFile);
      final id = await api.uploadAvatarFile(compressedFile);
      final name = basename(compressedFile.path);
      avatar = Avatar(fileId: id, fileName: name, fileBlurHash: blur);
    }

    var conversation = await api.updateConversation(
        id,
        name,
        description,
        addParticipants?.map((user) => user.id!).toList(),
        removeParticipants?.map((user) => user.id!).toList(),
        avatar);

    var result = (await localDatasource.getConversationLocal(id))!.copyWith(
        name: conversation.name!,
        description: conversation.description,
        avatar: conversation.avatar?.toAvatarModel());
    localDatasource.updateConversationLocal(result);
    _conversationsController.add(result);
    return result;
  }

  Future<bool> deleteConversation(ConversationModel conversation) async {
    var result = await api.deleteConversation(conversation.id);
    if (result) localDatasource.removeConversationLocal(conversation.id);
    _conversationsController.add(conversation);
    return result;
  }

  ConversationModel _buildConversationModel(Conversation conversation,
      Map<String, UserModel> participants, UserModel? currentUser) {
    final opponent = participants[conversation.opponentId];
    //can be null if user deleted
    final owner = participants[conversation.ownerId];

    return ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: getConversationName(conversation, owner, opponent, currentUser),
        description: conversation.description,
        unreadMessagesCount: conversation.unreadMessagesCount)
      ..opponent = getConversationOpponent(owner, opponent, currentUser)
      ..owner = owner
      ..lastMessage = conversation.lastMessage?.toMessageModel()
      ..avatar =
          getConversationAvatar(conversation, owner, opponent, currentUser);
  }
}
