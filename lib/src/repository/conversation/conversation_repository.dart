import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
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
import '../../features/conversation/models/chat_message.dart';
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

  StreamSubscription<ChatMessage>? incomingMessagesSubscription;

  Stream<ConversationModel> get updateConversationStream =>
      _conversationsController.stream;

  bool _chatsFilter(ConversationModel c) =>
      c.type == 'u' && c.lastMessage == null || (c.isEncrypted ?? false);

  void initChatListeners() {
    if (incomingSystemMessagesSubscription != null) return;

    incomingSystemMessagesSubscription = api
        .MessagesManager.instance.systemChatMessagesStream
        .listen((message) async {
      var (participants, users) =
          await getParticipants([message.conversation!.id!]);
      var usersMap = getParticipantsAsMap(users);

      var chatParticipants =
          usersMap.entries.map((entry) => entry.value).toList();

      var currentUser = await userRepository.getCurrentUser();
      final opponent =
          usersMap[message.conversation!.opponentId] ?? usersMap[message.from!];

      final conversation = _buildConversationModel(
          message.conversation!, usersMap, chatParticipants, currentUser);

      if (message.type == SystemChatMessageType.conversationCreated) {
        final conversationStored =
            await localDatasource.getConversationLocal(message.cid);
        if (conversationStored != null) return;
        await localDatasource.saveConversationLocal(conversation);
      } else if (message.type == SystemChatMessageType.conversationUpdated) {
        final conversationStored =
            await localDatasource.getConversationLocal(message.cid);
        if (conversationStored != null) {
          var updatedConversation =
              conversationStored.copyWithItem(item: conversation);
          await localDatasource.updateConversationLocal(updatedConversation);
        } else {
          await localDatasource.saveConversationLocal(conversation);
        }
      } else if (message.type == SystemChatMessageType.conversationKicked) {
        await localDatasource.removeConversationLocal(message.cid);
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
      var ignoreUnsentOwnMsg = message.status.index > 1 || !message.isOwn;
      if (conversation != null && ignoreUnsentOwnMsg) {
        int? unreadMsgCountUpdated;
        if (!message.isOwn) {
          unreadMsgCountUpdated = (conversation.unreadMessagesCount ?? 0) + 1;
        }

        final updatedConversation = conversation.copyWith(
            lastMessage: message,
            unreadMessagesCount: unreadMsgCountUpdated,
            updatedAt: DateTime.now());
        await localDatasource.updateConversationLocal(updatedConversation);
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
    await localDatasource.updateConversationLocal(updatedConversation!);
    _conversationsController.add(updatedConversation);
  }

  Future<List<ConversationModel>> getStoredConversations() async {
    var conversations = await localDatasource.getAllConversationsLocal();
    return conversations.whereNot((c) => _chatsFilter(c)).toList();
  }

  Future<(Map<String, List<String>>, List<UserModel>)> getParticipants(
      List<String> cids) async {
    var (participants, users) = await api.fetchParticipants(cids);
    var usersModels = users.map((element) => element.toUserModel()).toList();
    var usersLocal = await userRepository.saveUsersLocal(usersModels);
    return (participants, usersLocal);
  }

  Future<List<UserModel>> updateParticipants(ConversationModel chat) async {
    var (participants, users) = await api.fetchParticipants([chat.id]);
    var usersModels = users.map((element) => element.toUserModel()).toList();
    var usersLocal = await userRepository.saveUsersLocal(usersModels);
    await updateConversationLocal(chat.copyWith(participants: usersLocal));
    return usersLocal;
  }

  Map<String, UserModel> getParticipantsAsMap(List<UserModel> users) {
    return {for (var v in users) v.id!: v};
  }

  Future<Resource<List<ConversationModel>>> getAllConversations(
      {DateTime? ltDate}) async {
    return NetworkBoundResources<List<ConversationModel>,
            List<ConversationModel>>()
        .asFuture(
      loadFromDb: () =>
          localDatasource.getAllConversationsLocal(ltDate: ltDate),
      shouldFetch: (data, slice) {
        var oldData = data?.take(10).toList();
        slice?.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        var result = data != null && !listEquals(oldData, slice);
        return result;
      },
      createCallSlice: () => _fetchConversationsWithParticipants(
          ltDate: ltDate ?? DateTime.now(), limit: 10),
      createCall: () => _fetchConversationsWithParticipants(ltDate: ltDate),
      saveCallResult: localDatasource.saveConversationsLocal,
      processResponse: (data) async {
        return data.whereNot((c) => _chatsFilter(c)).toList();
      },
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
      {DateTime? ltDate, int limit = 100}) async {
    final conversations = await api.fetchConversations({
      if (ltDate != null)
        'updated_at': {
          'lt': ltDate.toUtc().toIso8601String(),
        },
      'limit': limit,
    });

    final currentUser = await userRepository.getCurrentUser();
    final cids = conversations.map((element) => element.id!).toList();
    var (participants, users) = await getParticipants(cids);
    var usersMap = getParticipantsAsMap(users);

    final List<ConversationModel> result = conversations.map((conversation) {
      var chatParticipants = participants[conversation.id]!
          .map((id) => usersMap[id])
          .toList()
          .nonNulls
          .toList();

      return _buildConversationModel(
          conversation, usersMap, chatParticipants, currentUser);
    }).toList();

    return result;
  }

  Future<ConversationModel?> getConversationById(String cid) async {
    var conversation = await localDatasource.getConversationLocal(cid);

    if (conversation == null) {
      final conversation = (await fetchConversationsByIds([cid])).firstOrNull;
      if (conversation == null) return null;
      final currentUser = await userRepository.getCurrentUser();
      var (allParticipants, users) = await getParticipants([cid]);
      final usersMap = getParticipantsAsMap(users);
      var participantsModels =
          allParticipants[conversation.id]!.map((id) => usersMap[id]!).toList();
      return _buildConversationModel(
          conversation, usersMap, participantsModels, currentUser);
    }
    return conversation;
  }

  Future<ConversationModel?> fetchConversationById(String cid) async {
    final conversation = (await fetchConversationsByIds([cid])).firstOrNull;
    if (conversation == null) {
      //if no internet try return local conversation
      return localDatasource.getConversationLocal(cid);
    }
    final currentUser = await userRepository.getCurrentUser();
    var (allParticipants, users) = await getParticipants([cid]);
    final usersMap = getParticipantsAsMap(users);
    var participantsModels =
        allParticipants[conversation.id]!.map((id) => usersMap[id]!).toList();
    var conversationModel = _buildConversationModel(
        conversation, usersMap, participantsModels, currentUser);
    localDatasource.updateConversationLocal(conversationModel);
    return conversationModel;
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

  Future<void> updateConversationLocal(ConversationModel chat) async {
    await localDatasource.updateConversationLocal(chat);
    _conversationsController.add(chat);
  }

  Future<bool> deleteConversation(ConversationModel conversation) async {
    var result = await api.deleteConversation(conversation.id);
    if (result) await localDatasource.removeConversationLocal(conversation.id);
    _conversationsController.add(conversation);
    return result;
  }

  ConversationModel _buildConversationModel(
      Conversation conversation,
      Map<String, UserModel> users,
      List<UserModel> participants,
      UserModel? currentUser) {
    final opponent = users[conversation.opponentId];
    //can be null if user deleted
    final owner = users[conversation.ownerId];
    var isOwn = currentUser?.id == conversation.lastMessage?.from;

    return ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: getConversationName(conversation, owner, opponent, currentUser),
        description: conversation.description,
        unreadMessagesCount: conversation.unreadMessagesCount,
        isEncrypted: conversation.isEncrypted)
      ..opponent = getConversationOpponent(owner, opponent, currentUser)
      ..owner = owner
      ..lastMessage = conversation.lastMessage
          ?.toMessageModel(isOwn: isOwn) // maybe set cid from chat
      ..avatar =
          getConversationAvatar(conversation, owner, opponent, currentUser)
      ..participants.addAll(participants);
  }
}
