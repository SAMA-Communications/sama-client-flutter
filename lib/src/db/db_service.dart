import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../objectbox.g.dart';
import 'models/conversation_model.dart';
import 'models/message_model.dart';
import 'models/user_model.dart';

const dbName = 'SamaObjectBox';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  static Store? store;

  void init() async {
    store ??= await _create();
  }

  Future<Store> _create() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDir.path, dbName);
    final store = await openStore(directory: dbPath);
    return store;
  }

  void drop() async {
    try {
      close();
      var dir = await getApplicationDocumentsDirectory();
      Directory('${dir.path}/$dbName').deleteSync(recursive: true);
      print(
          'drop $dbName exists ${await Directory('${dir.path}/$dbName').exists()}');
    } catch (e) {
      print('drop e ${e}');
      return;
    }
  }

  void close() async {
    try {
      store?.close();
      store = null;
    } catch (e) {
      return;
    }
  }

  /// ////////////////////////////////
  /// Conversation Store Functions ///
  /// ////////////////////////////////

  Future<List<ConversationModel>> getAllConversationsLocal(
      DateTime? ltDate) async {
    var filter = ConversationModel_.type
        .equals('u')
        .and(ConversationModel_.lastMessageBind.notEquals(0).and(
            ConversationModel_.updatedAt
                .lessThanDate(ltDate ?? DateTime.now())))
        .or(ConversationModel_.type.equals('g'));

    final query = store!
        .box<ConversationModel>()
        // .query(filtered ? filter : null)
        .query(
            ConversationModel_.updatedAt.lessThanDate(ltDate ?? DateTime.now()))
        .order(ConversationModel_.updatedAt, flags: Order.descending)
        .build();
    final results = await query.findAsync();
    query.close();
    return results;
  }

  Future<ConversationModel?> getConversationLocal(String cid) async {
    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.id.equals(cid))
        .build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<ConversationModel?> getConversationLocalByMsgId(String id) async {
    final lastMessage = await getMessageLocal(id);

    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.lastMessageBind.equals(lastMessage!.bid!))
        .build();
    final result = await query.findFirstAsync();
    query.close();
    return result;
  }

  Future<MessageModel> updateConversationLastMessage(MessageModel item) async {
    return store!.box<MessageModel>().putAndGetAsync(item, mode: PutMode.put);
  }

  Future<List<ConversationModel>> getConversationsLocal(
      List<String> ids) async {
    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.id.oneOf(ids))
        .build();
    final results = query.findAsync();
    query.close();
    return results;
  }

  Future<bool> saveConversationsLocal(List<ConversationModel> items) async {
// https://docs.objectbox.io/entity-annotations#unique-constraints need to be updated manually
    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.id
            .oneOf(items.map((element) => element.id).toList()))
        .build();

    final chatsInDb = await query.findAsync();
    query.close();

    var chatsInDbMap = {for (var v in chatsInDb) v.id: v};
    for (var chat in items) {
      final chatInDb = chatsInDbMap[chat.id];
      if (chatInDb != null) {
        await assignConversation(chat, chatInDb);
      }
    }

    await store!
        .box<ConversationModel>()
        .putManyAsync(items, mode: PutMode.put);
    return true;
  }

  Future<bool> saveConversationLocal(ConversationModel item) async {
    await store!.box<ConversationModel>().putAsync(item, mode: PutMode.put);
    return true;
  }

  Future<bool> updateConversationLocal(ConversationModel item) async {
    if (item.bid == null) {
      final query = store!
          .box<ConversationModel>()
          .query(ConversationModel_.id.equals(item.id))
          .build();
      final chatInDb = await query.findFirstAsync();
      query.close();

      if (chatInDb != null) {
        await assignConversation(item, chatInDb);
      }
    }
    await store!.box<ConversationModel>().putAsync(item, mode: PutMode.put);
    return true;
  }

  Future<bool> removeConversationLocal(String id) async {
    final query = store!
        .box<ConversationModel>()
        .query(ConversationModel_.id.equals(id))
        .build();
    var result = await query.removeAsync();
    query.close();
    // final item = await query.findFirstAsync();
    // query.close();
    // await store!.box<ConversationModel>().removeAsync(item!.bid!);
    return true;
  }

  Future<void> assignConversation(
      ConversationModel chat, ConversationModel chatInDb) async {
    chat.bid = chatInDb.bid;
    chat.opponent?.bid = chatInDb.opponent?.bid;
    if (chatInDb.owner?.id == chat.owner?.id) {
      chat.owner?.bid = chatInDb.owner?.bid;
    }
    if (chatInDb.avatar?.fileId == chat.avatar?.fileId) {
      chat.avatar?.bid = chatInDb.avatar?.bid;
    }
    if (chatInDb.lastMessage?.id == chat.lastMessage?.id) {
      chat.lastMessage?.bid = chatInDb.lastMessage?.bid;

      if (chat.lastMessage != chatInDb.lastMessage) {
        var msg = chatInDb.lastMessage
            ?.copyWith(rawStatus: chat.lastMessage?.rawStatus);
        await store!.box<MessageModel>().putAsync(msg!, mode: PutMode.update);
      }
    } else {
      final lastMessage = await getMessageLocal(chat.lastMessage!.id!);
      chat.lastMessage?.bid = lastMessage?.bid;
    }
  }

  /// ////////////////////////
  /// User Store Functions ///
  /// ////////////////////////

  Future<UserModel?> getUserLocal(String id) async {
    final query =
        store!.box<UserModel>().query(UserModel_.id.equals(id)).build();
    final user = query.findFirst();
    query.close();
    return user;
  }

  Future<UserModel> saveUserLocal(UserModel item) async {
    return store!.box<UserModel>().putAndGetAsync(item, mode: PutMode.put);
  }

  Future<UserModel> updateUserLocal(UserModel item) async {
    final query =
        store!.box<UserModel>().query(UserModel_.id.equals(item.id!)).build();
    final userInDb = query.findFirst();
    query.close();

    item.bid = userInDb?.bid;
    if (userInDb?.avatar?.fileId == item.avatar?.fileId) {
      item.avatar?.bid = userInDb?.avatar?.bid;
    }
    return store!.box<UserModel>().putAndGetAsync(item, mode: PutMode.put);
  }

  Future<List<UserModel>> saveUsersLocal(List<UserModel> items) async {
    final query = store!
        .box<UserModel>()
        .query(
            UserModel_.id.oneOf(items.map((element) => element.id!).toList()))
        .build();
    var usersInDb = await query.findAsync();
    query.close();

    var usersMap = {for (var v in usersInDb) v.id!: v};
    for (var user in items) {
      final userInDb = usersMap[user.id];
      user.bid = userInDb?.bid;
      if (userInDb?.avatar?.fileId == user.avatar?.fileId) {
        user.avatar?.bid = userInDb?.avatar?.bid;
      }
    }
    return store!.box<UserModel>().putAndGetManyAsync(items, mode: PutMode.put);
  }

  Future<List<UserModel>> getUsersModelLocal(List<String> ids) async {
    final query =
        store!.box<UserModel>().query(UserModel_.id.oneOf(ids)).build();
    final results = query.findAsync();
    query.close();
    return results;
  }

  /// ///////////////////////////
  /// Message Store Functions ///
  /// ///////////////////////////

  Future<List<MessageModel>> getAllMessagesLocal(
      String cid, DateTime? ltDate) async {
    final query = store!
        .box<MessageModel>()
        .query(MessageModel_.cid.equals(cid).and(
            MessageModel_.createdAt.lessThanDate(ltDate ?? DateTime.now())))
        .order(MessageModel_.createdAt, flags: Order.descending)
        .build();
    final results = await query.findAsync();
    query.close();
    return results;
  }

  Future<bool> saveMessagesLocal(List<MessageModel> items) async {
    final query = store!
        .box<MessageModel>()
        .query(MessageModel_.id
            .oneOf(items.map((element) => element.id!).toList()))
        .build();

    final messagesInDb = await query.findAsync();
    query.close();

    var messagesInDbMap = {for (var v in messagesInDb) v.id: v};
    for (var message in items) {
      final messageInDb = messagesInDbMap[message.id];
      if (messageInDb != null) {
        message.bid = messageInDb.bid;
        // message.attachments?.forEach((a) {
        //   a.bid = messageInDb.attachments.bid ;
        // }
      }
    }

    await store!.box<MessageModel>().putManyAsync(items, mode: PutMode.put);
    return true;
  }

  Future<MessageModel?> getMessageLocal(String id) async {
    final query =
        store!.box<MessageModel>().query(MessageModel_.id.equals(id)).build();
    final message = query.findFirst();
    query.close();
    return message;
  }

  Future<List<MessageModel>> getMessagesLocal(List<String> ids) async {
    final query =
        store!.box<MessageModel>().query(MessageModel_.id.oneOf(ids)).build();
    final results = query.findAsync();
    query.close();
    return results;
  }

  Future<bool> saveMessageLocal(MessageModel item) async {
    await store!.box<MessageModel>().putAsync(item, mode: PutMode.put);
    return true;
  }

  Future<MessageModel> updateMessageLocal(MessageModel item) async {
    if (item.bid == null) {
      final query = store!
          .box<MessageModel>()
          .query(MessageModel_.id.equals(item.id!))
          .build();
      final msgInDb = await query.findFirstAsync();
      query.close();

      if (msgInDb != null) {
        assignMessage(item, msgInDb);
      }
    }
    return await store!
        .box<MessageModel>()
        .putAndGetAsync(item, mode: PutMode.put);
  }

  Future<void> assignMessage(MessageModel msg, MessageModel msgInDb) async {
    msg.bid = msgInDb.bid;
  }
}
