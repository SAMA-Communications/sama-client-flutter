import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import '../../api/api.dart' as api;
import '../../api/api.dart';
import '../../api/push_notifications/models/models.dart';
import '../../db/entity_builder.dart';
import '../../db/models/conversation_model.dart';
import '../../db/models/user_model.dart';
import '../../db/network_bound_resource.dart';
import '../../db/resource.dart';
import '../../repository/messages/messages_repository.dart';
import '../../shared/utils/media_utils.dart';
import '../../shared/utils/string_utils.dart';
import '../user/user_repository.dart';
import '../../db/local/conversation_local_datasource.dart';

class ConversationRepository {
  final ConversationLocalDataSource localDataSource;

  // final ConversationRemoteDataSource remoteDataSource;

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
      final opponent = participants[message.conversation!.opponentId] ??
          participants[message.from!];
      final owner = participants[message.conversation!.ownerId];

      final conversation = ConversationModel(
          id: message.conversation!.id!,
          createdAt: message.conversation!.createdAt!,
          updatedAt: message.conversation!.updatedAt!,
          type: message.conversation!.type!,
          name: getConversationName(
              message.conversation!, owner, opponent, localUser),
          unreadMessagesCount: message.conversation!.unreadMessagesCount,
          description: message.conversation!.description)
        ..opponent =
            buildWithUser(getConversationOpponent(owner, opponent, localUser))
        ..owner = buildWithUser(owner)
        ..lastMessage = buildWithMessage(message.conversation!.lastMessage)
        ..avatar = buildWithAvatar(getConversationAvatar(
            message.conversation!, owner, opponent, localUser));
      if (message.type == SystemChatMessageType.conversationCreated) {
        localDataSource.saveConversationLocal(conversation);
      } else if (message.type == SystemChatMessageType.conversationUpdated) {
        final conversationStored =
            await localDataSource.getConversationLocal(message.cid);
        if (conversationStored != null) {
          var updatedConversation =
              conversationStored.copyWithItem(item: conversation);
          localDataSource.updateConversationLocal(updatedConversation);
        } else {
          localDataSource.saveConversationLocal(conversation);
        }
      } else if (message.type == SystemChatMessageType.conversationKicked) {
        localDataSource.removeConversationLocal(message.cid);
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
          await localDataSource.getConversationLocal(message.cid!);
      if (conversation != null) {
        int? unreadMsgCountUpdated;
        if (!message.isOwn) {
          unreadMsgCountUpdated = (conversation.unreadMessagesCount ?? 0) + 1;
        }

        final updatedConversation = conversation.copyWith(
            lastMessage: buildWithMessage(message),
            unreadMessagesCount: unreadMsgCountUpdated);
        localDataSource.updateConversationLocal(updatedConversation);
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
        await localDataSource.getConversationLocal(conversationId);
    final updatedConversation = conversation?.copyWith(unreadMessagesCount: 0);
    localDataSource.updateConversationLocal(updatedConversation!);
    _conversationsController.add(updatedConversation);
  }

  Future<List<ConversationModel>> getStoredConversations() async {
    var conversations = await localDataSource.getAllConversationsLocal();
    _removeEmptyPrivateConversations(conversations);
    return conversations;
  }

  Future<List<UserModel>> getParticipants(List<String> cids) async {
    //FixME RP later with storage mechanism
    // if (_participants.isNotEmpty) return _participants.values.toList();

    return (await api.fetchParticipants(cids))
        .map((element) => buildWithUser(element)!)
        .toList();
  }

  Future<Map<String, api.User>> getParticipantsAsMap(List<String> cids) async {
    //FixME RP later with storage mechanism
    return {for (var v in await api.fetchParticipants(cids)) v.id!: v};
  }

  //TODO RP remove if no need - get conversations as stream
  StreamSubscription<Resource<List<ConversationModel>>>?
      updateConversationsSubscription;

  void requireAllConversations() async {
    updateConversationsSubscription?.cancel();
    updateConversationsSubscription = NetworkBoundResources<
            List<ConversationModel>, List<ConversationModel>>()
        .asStream(
      loadFromDb: localDataSource.getAllConversationsLocal,
      shouldFetch: (data) => data == null || data.isEmpty,
      createCall: _fetchConversationsWithParticipants,
      saveCallResult: localDataSource.saveConversationsLocal,
    )
        .listen((result) async {
      switch (result.status) {
        case Status.loading:
          print(' getAllInitialConversations Status.loading ${result.data}');
        // if (result.data != null) _conversationsController.add(result.data!);
        case Status.success:
          print('getAllInitialConversations Status.success ${result.data}');
        // _conversationsController.add(result.data!);
        case Status.failed:
          print('getAllInitialConversations Status.failed ${result.error}');
        default:
          print('getAllInitialConversations default');
      }
    });
  }

  Future<Resource<List<ConversationModel>>> getAllConversations() async {
    return NetworkBoundResources<List<ConversationModel>,
            List<ConversationModel>>()
        .asFuture(
      loadFromDb: localDataSource.getAllConversationsLocal,
      shouldFetch: (data, slice) {
        // var oldData = data?.take(10).toList();
        // var result = data != null && !listEquals(oldData, slice);
        return true;
      },
      // createCallSlice: () => _fetchConversationsWithParticipants(10),
      createCall: _fetchConversationsWithParticipants,
      saveCallResult: localDataSource.saveConversationsLocal,
    );
  }

  Future<Resource<ConversationModel?>> getConversation(String id) async {
    return NetworkBoundResources<ConversationModel?, ConversationModel?>()
        .asFuture(
      loadFromDb: () => localDataSource.getConversationLocal(id),
      shouldFetch: (data, slice) => data == null,
      createCall: () => getOneConversationById(id),
      saveCallResult: (data) => data != null
          ? localDataSource.saveConversationLocal(data)
          : Future.value(false),
    );
  }

  Future<List<ConversationModel>> _fetchConversationsWithParticipants(
      [int limit = 100]) async {
    final conversations = await api.fetchConversations({
      // 'updated_at': {
      //   'lt': DateTime.now().toIso8601String(),
      // },
      'limit': limit,
    });

    final cids = conversations.map((element) => element.id!).toList();
    final localUser = await userRepository.getLocalUser();
    final participants = await getParticipants(cids);

    var usersDB = await localDataSource.saveUsersLocal(participants);

    // List<ConversationModel> result =
    //     conversations.fold<List<ConversationModel>>([], (prev, conversation) {
    //   if (conversation.type == 'u' && conversation.lastMessage == null) {
    //     return prev;
    //   }
    //   var chat = _buildConversationModel(conversation, participants, localUser);
    //   prev.add(chat);
    //   return prev;
    // }).toList();

    var usersMap = {for (var v in usersDB) v.id!: v};
    final List<ConversationModel> result = conversations.map((conversation) {
      var chat = _buildConversationModel2(conversation, usersMap, localUser);
      return chat;
    }).toList();
    _removeEmptyPrivateConversations(result);
    return result;
  }

  Future<ConversationModel?> getOneConversationById(String cid) async {
    var conversation = await localDataSource.getConversationLocal(cid);

    if (conversation == null) {
      final conversation = (await fetchConversationsByIds([cid])).firstOrNull;
      if (conversation == null) return null;
      final localUser = await userRepository.getLocalUser();
      final participants = await getParticipantsAsMap([cid]);
      return _buildConversationModel(conversation, participants, localUser);
    }
    return null;
  }

  Future<ConversationModel?> getConversationById(String cid) async {
    var conversation = await localDataSource.getConversationLocal(cid);

    if (conversation == null) {
      final conversation = (await fetchConversationsByIds([cid])).firstOrNull;
      if (conversation == null) return null;
      final localUser = await userRepository.getLocalUser();
      final participants = await getParticipantsAsMap([cid]);
      return _buildConversationModel(conversation, participants, localUser);
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

    var localUser = await userRepository.getLocalUser();
    final opponent = participantsMap[conversation.opponentId];
    final owner = localUser;
    var result = ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: getConversationName(
            conversation, owner, buildWithUserModel(opponent), localUser),
        unreadMessagesCount: conversation.unreadMessagesCount)
      ..opponent = buildWithUser(getConversationOpponent(
          owner, buildWithUserModel(opponent), localUser))
      ..owner = buildWithUser(owner)
      ..lastMessage = buildWithMessage(conversation.lastMessage)
      ..avatar = buildWithAvatar(getConversationAvatar(
          conversation, owner, buildWithUserModel(opponent), localUser));

    localDataSource.saveConversationLocal(result);
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

    var result = (await localDataSource.getConversationLocal(id))!.copyWith(
        name: conversation.name!,
        description: conversation.description,
        avatar: buildWithAvatar(conversation.avatar));
    localDataSource.updateConversationLocal(result);
    _conversationsController.add(result);
    return result;
  }

  Future<bool> deleteConversation(ConversationModel conversation) async {
    var result = await api.deleteConversation(conversation.id);
    if (result) localDataSource.removeConversationLocal(conversation.id);
    _conversationsController.add(conversation);
    return result;
  }

  //add sort to localStore
  void _sortConversations(List<ConversationModel> items) {
    items.sort((a, b) => (b.lastMessage?.createdAt ?? b.updatedAt)
        .compareTo(a.lastMessage?.createdAt ?? a.updatedAt));
  }

  void _removeEmptyPrivateConversations(List<ConversationModel> items) {
    items.removeWhere((i) => i.type == 'u' && i.lastMessage == null);
  }

  ConversationModel _buildConversationModel(Conversation conversation,
      Map<String, api.User> participants, api.User? localUser) {
    final opponent = participants[conversation.opponentId];
    //can be null if user deleted
    final owner = participants[conversation.ownerId];

    return ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: getConversationName(conversation, owner, opponent, localUser),
        description: conversation.description,
        unreadMessagesCount: conversation.unreadMessagesCount)
      ..opponent =
          buildWithUser(getConversationOpponent(owner, opponent, localUser))
      ..owner = buildWithUser(owner)
      ..lastMessage = buildWithMessage(conversation.lastMessage)
      ..avatar = buildWithAvatar(
          getConversationAvatar(conversation, owner, opponent, localUser));
  }

  ConversationModel _buildConversationModel2(Conversation conversation,
      Map<String, UserModel> participants, api.User? localUser) {
    final opponent = participants[conversation.opponentId];
    //can be null if user deleted
    final owner = participants[conversation.ownerId];

    return ConversationModel(
        id: conversation.id!,
        createdAt: conversation.createdAt!,
        updatedAt: conversation.updatedAt!,
        type: conversation.type!,
        name: getConversationModelName(conversation, owner, opponent, localUser),
        description: conversation.description,
        unreadMessagesCount: conversation.unreadMessagesCount)
      ..opponent = getConversationModelOpponent(owner, opponent, localUser)
      ..owner = owner
      ..lastMessage = buildWithMessage(conversation.lastMessage)
      ..avatar = getConversationModelAvatar(conversation, owner, opponent, localUser);
  }
}
